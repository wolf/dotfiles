"""Shared fixtures and fake-data builders for `jpr-recordings.py` tests."""

import base64
import json
import os
import sys
from importlib import util
from pathlib import Path

SCRIPT_PATH = Path(__file__).parent.parent / "jpr-recordings.py"

_spec = util.spec_from_file_location("jpr_recordings", SCRIPT_PATH)
jpr_recordings = util.module_from_spec(_spec)
sys.modules["jpr_recordings"] = jpr_recordings
_spec.loader.exec_module(jpr_recordings)


def jpr_blob(transcript: str) -> bytes:
    """Build a `JPR2{...}` JSON blob with `transcript` base64-encoded inside."""
    encoded = base64.b64encode(transcript.encode("utf-8")).decode("ascii")
    obj = {"_root": {"txscriptv2": {"tx": {"_data": encoded}}}}
    return b"JPR2" + json.dumps(obj).encode("utf-8")


def make_recording(root: Path, date: str, time_str: str, data: bytes) -> Path:
    """Write a fake recording at `<root>/<date>/<time_str>.m4a` and return its path."""
    day_dir = root / date
    day_dir.mkdir(parents=True, exist_ok=True)
    path = day_dir / f"{time_str}.m4a"
    path.write_bytes(data)
    return path


def install_fake_brctl(monkeypatch, tmp_path: Path, payload: bytes | None) -> None:
    """
    Put a fake `brctl` first on `PATH`.

    `payload=None` makes it a no-op, simulating a download that never
    arrives. Otherwise it copies `payload` to whatever path it's asked to
    download, simulating a successful materialization.
    """
    bin_dir = tmp_path / "fakebin"
    bin_dir.mkdir(exist_ok=True)
    script = bin_dir / "brctl"
    if payload is None:
        body = "#!/usr/bin/env python3\n"
    else:
        payload_path = tmp_path / "_fake_payload.bin"
        payload_path.write_bytes(payload)
        body = (
            "#!/usr/bin/env python3\n"
            "import shutil, sys\n"
            "if sys.argv[1] == 'download':\n"
            f"    shutil.copyfile({str(payload_path)!r}, sys.argv[2])\n"
        )
    script.write_text(body)
    script.chmod(0o755)
    monkeypatch.setenv("PATH", f"{bin_dir}{os.pathsep}{os.environ['PATH']}")
