#!/usr/bin/env -S uv run --no-project --script --quiet
# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "loguru",
#     "typer",
# ]
# ///
"""
Scan and safely delete Just Press Record (JPR) voice-note recordings.

JPR is Apple-ecosystem only, and this script leans on that: recordings live
in iCloud Drive (`~/Library/Mobile Documents/...`), and a not-yet-downloaded
recording is materialized with `brctl`, a macOS-only tool. This script does
not run anywhere else.

Each recording is a `.m4a` file at `<root>/YYYY-MM-DD/HH-MM-SS.m4a`. JPR
embeds its transcript as a JSON blob directly in the file's binary data,
marked by the literal ASCII prefix `JPR2{`. `scan` finds that blob, brace
matches it out, and base64-decodes the transcript inside. `delete` removes
one or more recordings, but only after re-extracting each one to confirm it
still holds a real transcript.
"""

import base64
import json
import re
import subprocess
import sys
import time
from dataclasses import asdict, dataclass
from pathlib import Path

import typer
from loguru import logger

__version__ = "1.0.0"

app = typer.Typer(add_completion=False, no_args_is_help=True)

DEFAULT_ROOT = (
    Path.home() / "Library" / "Mobile Documents" / "iCloud~com~openplanetsoftware~just-press-record" / "Documents"
)

_DATE_DIR_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
_RECORDING_NAME_RE = re.compile(r"^\d{2}-\d{2}-\d{2}\.m4a$")
_PLACEHOLDER_NAME_RE = re.compile(r"^\.(\d{2}-\d{2}-\d{2}\.m4a)\.icloud$")
_TRANSCRIPT_MARKER = b"JPR2{"

STATUS_READY = "ready"
STATUS_UNTRANSCRIBED = "untranscribed"
STATUS_DOWNLOADING = "downloading"
STATUS_UNREADABLE = "unreadable"


@dataclass
class Recording:
    """One JPR recording and the outcome of scanning it."""

    path: str
    recorded_at: str
    status: str
    transcript: str | None = None
    detail: str | None = None


def _parse_recorded_at(path: Path) -> str:
    """
    Parse a recording's timestamp from its `YYYY-MM-DD/HH-MM-SS.m4a` path.

    >>> _parse_recorded_at(Path("root/2026-09-23/06-34-10.m4a"))
    '2026-09-23T06:34:10'
    """
    date_part = path.parent.name
    time_part = path.stem.replace("-", ":")
    return f"{date_part}T{time_part}"


def _brace_match(data: bytes, start: int) -> bytes:
    """
    Extract one balanced `{...}` JSON object from `data` starting at `start`.

    Tracks JSON string and escape state so a brace inside a quoted string
    doesn't affect the depth count.

    >>> _brace_match(b'{"a": 1}trailing junk', 0)
    b'{"a": 1}'
    >>> _brace_match(b'{"x": "}"}', 0)
    b'{"x": "}"}'

    Raises `ValueError` if `start` isn't a `{`, or the object never closes.
    """
    if data[start : start + 1] != b"{":
        raise ValueError(f"expected '{{' at offset {start}")
    depth = 0
    in_string = False
    escape = False
    for i in range(start, len(data)):
        c = data[i]
        if in_string:
            if escape:
                escape = False
            elif c == 0x5C:  # backslash
                escape = True
            elif c == 0x22:  # quote
                in_string = False
        elif c == 0x22:
            in_string = True
        elif c == 0x7B:  # {
            depth += 1
        elif c == 0x7D:  # }
            depth -= 1
            if depth == 0:
                return data[start : i + 1]
    raise ValueError("unterminated JSON object")


def _extract(path: Path, recorded_at: str) -> Recording:
    """Read `path` and classify it as ready, untranscribed, or unreadable."""
    try:
        data = path.read_bytes()
    except OSError as exc:
        return Recording(str(path), recorded_at, STATUS_UNREADABLE, detail=str(exc))

    marker_start = data.find(_TRANSCRIPT_MARKER)
    if marker_start == -1:
        return Recording(str(path), recorded_at, STATUS_UNTRANSCRIBED)

    json_start = marker_start + len(_TRANSCRIPT_MARKER) - 1  # the '{' itself
    try:
        blob = _brace_match(data, json_start)
        obj = json.loads(blob)
        encoded = obj["_root"]["txscriptv2"]["tx"]["_data"]
        transcript = base64.b64decode(encoded).decode("utf-8")
    except (ValueError, KeyError, TypeError, json.JSONDecodeError, UnicodeDecodeError) as exc:
        detail = f"{type(exc).__name__}: {exc}"
        return Recording(str(path), recorded_at, STATUS_UNREADABLE, detail=detail)

    return Recording(str(path), recorded_at, STATUS_READY, transcript=transcript)


def _discover(root: Path) -> list[tuple[Path, bool]]:
    """
    Find every recording under `root`, real or still-a-placeholder.

    Returns `(path, is_placeholder)` pairs, sorted oldest first. `path` is
    always the recording's real target name, even when only a placeholder
    currently exists on disk.
    """
    found: dict[Path, bool] = {}
    if not root.is_dir():
        logger.debug(f"root does not exist: {root}")
        return []
    for day_dir in root.iterdir():
        if not day_dir.is_dir() or not _DATE_DIR_RE.match(day_dir.name):
            continue
        for entry in day_dir.iterdir():
            if _RECORDING_NAME_RE.match(entry.name):
                found[entry] = False
            else:
                match = _PLACEHOLDER_NAME_RE.match(entry.name)
                if match:
                    found[day_dir / match.group(1)] = True
    logger.debug(f"found {len(found)} recording(s) under {root}")
    return sorted(found.items(), key=lambda pair: str(pair[0]))


def _materialize(placeholders: list[Path], timeout: float) -> set[Path]:
    """
    Request download of every placeholder, then poll until each is stable.

    Returns the subset still missing (or still changing size) when `timeout`
    runs out — these are reported as `downloading`, never deleted.
    """
    if not placeholders:
        return set()

    logger.info(f"requesting download for {len(placeholders)} placeholder(s)")
    for path in placeholders:
        subprocess.run(["brctl", "download", str(path)], capture_output=True)

    pending = set(placeholders)
    last_size: dict[Path, int] = {}
    deadline = time.monotonic() + timeout
    while pending and time.monotonic() < deadline:
        for path in list(pending):
            if not path.exists():
                continue
            size = path.stat().st_size
            if size > 0 and last_size.get(path) == size:
                pending.discard(path)
            else:
                last_size[path] = size
        if pending:
            time.sleep(1)
    if pending:
        logger.warning(f"{len(pending)} placeholder(s) still not materialized after {timeout}s")
    return pending


def _scan(root: Path, timeout: float) -> list[Recording]:
    discovered = _discover(root)
    still_downloading = _materialize([p for p, is_ph in discovered if is_ph], timeout)

    results = []
    for path, _ in discovered:
        recorded_at = _parse_recorded_at(path)
        if path in still_downloading:
            results.append(Recording(str(path), recorded_at, STATUS_DOWNLOADING))
        else:
            results.append(_extract(path, recorded_at))
    return results


def _version_callback(value: bool) -> None:
    if value:
        print(__version__)
        raise typer.Exit()


@app.callback()
def main(
    version: bool | None = typer.Option(
        None, "--version", "-V", callback=_version_callback, is_eager=True, help="Show the version and exit."
    ),
    log_level: str = typer.Option("WARNING", "--log-level", help="DEBUG, INFO, WARNING, or ERROR."),
    log_file: Path | None = typer.Option(None, "--log-file", help="Also write logs to this path."),
) -> None:
    """Scan and safely delete Just Press Record voice-note recordings."""
    logger.remove()
    logger.add(sys.stderr, level=log_level)
    if log_file is not None:
        logger.add(log_file, level=log_level)


@app.command()
def scan(
    root: Path = typer.Option(DEFAULT_ROOT, "--root", help="JPR recordings folder."),
    timeout: float = typer.Option(60.0, "--timeout", help="Seconds to wait for placeholder downloads."),
) -> None:
    """Scan for recordings and print their status as a JSON array, oldest first."""
    results = _scan(root, timeout)
    print(json.dumps([asdict(r) for r in results], indent=2))


@app.command()
def delete(
    paths: list[Path] = typer.Argument(..., help="Recording(s) to delete, as one all-or-nothing group."),
    root: Path = typer.Option(DEFAULT_ROOT, "--root", help="JPR recordings folder."),
) -> None:
    """
    Delete one or more recordings, but only if every one re-validates.

    Each path must resolve under `root`, be a real recording file, and
    re-extract to a non-empty transcript. If any path fails, nothing is
    deleted — the group goes whole or not at all.
    """
    root = root.resolve()
    errors: list[str] = []
    resolved: list[Path] = []
    for raw_path in paths:
        path = raw_path.resolve()
        resolved.append(path)
        if not path.is_relative_to(root):
            errors.append(f"{path}: not under root {root}")
        elif not _RECORDING_NAME_RE.match(path.name):
            errors.append(f"{path}: not a recording filename")
        elif not path.is_file():
            errors.append(f"{path}: does not exist")
        else:
            recording = _extract(path, _parse_recorded_at(path))
            if recording.status != STATUS_READY or not recording.transcript:
                errors.append(f"{path}: not a transcribed recording ({recording.status})")

    if errors:
        for error in errors:
            logger.error(error)
        raise typer.Exit(1)

    for path in resolved:
        path.unlink()
    logger.info(f"deleted {len(resolved)} recording(s)")


if __name__ == "__main__":
    app()
