"""Tests for `jpr-recordings.py` — these test its promises, not its internals."""

import doctest
import json
import subprocess

import pytest
from conftest import SCRIPT_PATH, install_fake_brctl, jpr_blob, jpr_recordings, make_recording
from typer.testing import CliRunner

runner = CliRunner()


class TestBraceMatch:
    def test_extracts_balanced_object_ignoring_trailing_junk(self):
        assert jpr_recordings._brace_match(b'{"a": 1}trailing junk', 0) == b'{"a": 1}'

    def test_ignores_braces_and_quotes_inside_strings(self):
        data = b'{"x": "}", "y": "\\"}\\""}'
        result = jpr_recordings._brace_match(data, 0)
        assert json.loads(result) == {"x": "}", "y": '"}"'}

    def test_raises_on_unterminated_object(self):
        with pytest.raises(ValueError):
            jpr_recordings._brace_match(b'{"a": 1', 0)

    def test_raises_when_start_is_not_a_brace(self):
        with pytest.raises(ValueError):
            jpr_recordings._brace_match(b'not json {"a": 1}', 0)


class TestModuleDoctests:
    def test_doctests_pass(self):
        # Explicit doctest.testmod(), not pytest's --doctest-modules: that flag
        # collects by importing "jpr-recordings.py" under its own filename,
        # which isn't a valid module name (the hyphen). conftest already
        # loaded it under the importable name "jpr_recordings" via importlib.
        results = doctest.testmod(jpr_recordings, verbose=False)
        assert results.failed == 0


class TestScan:
    def test_extracts_transcript_embedded_in_binary_junk(self, tmp_path):
        data = b"\x00\x01RIFF....junk...." + jpr_blob("hello world") + b"\x00\x00trailer"
        make_recording(tmp_path, "2026-09-23", "06-34-10", data)

        result = runner.invoke(jpr_recordings.app, ["scan", "--root", str(tmp_path)])

        assert result.exit_code == 0
        (recording,) = json.loads(result.stdout)
        assert recording["status"] == "ready"
        assert recording["transcript"] == "hello world"
        assert recording["recorded_at"] == "2026-09-23T06:34:10"

    def test_untranscribed_when_no_marker(self, tmp_path):
        make_recording(tmp_path, "2026-09-23", "06-34-10", b"no marker in here")

        result = runner.invoke(jpr_recordings.app, ["scan", "--root", str(tmp_path)])

        (recording,) = json.loads(result.stdout)
        assert recording["status"] == "untranscribed"

    def test_unreadable_when_blob_is_truncated(self, tmp_path):
        make_recording(tmp_path, "2026-09-23", "06-34-10", b'JPR2{"_root": {"incomplete":')

        result = runner.invoke(jpr_recordings.app, ["scan", "--root", str(tmp_path)])

        (recording,) = json.loads(result.stdout)
        assert recording["status"] == "unreadable"
        assert recording["detail"]

    def test_batch_continues_after_an_unreadable_recording(self, tmp_path):
        make_recording(tmp_path, "2026-09-23", "06-00-00", b'JPR2{"broken":')
        make_recording(tmp_path, "2026-09-23", "07-00-00", b"prefix" + jpr_blob("still works"))

        result = runner.invoke(jpr_recordings.app, ["scan", "--root", str(tmp_path)])

        recordings = json.loads(result.stdout)
        assert [r["status"] for r in recordings] == ["unreadable", "ready"]
        assert recordings[1]["transcript"] == "still works"

    def test_results_sorted_chronologically_across_days(self, tmp_path):
        make_recording(tmp_path, "2026-09-23", "06-00-00", b"prefix" + jpr_blob("morning on the 23rd"))
        make_recording(tmp_path, "2026-09-22", "23-00-00", b"prefix" + jpr_blob("late on the 22nd"))

        result = runner.invoke(jpr_recordings.app, ["scan", "--root", str(tmp_path)])

        recordings = json.loads(result.stdout)
        assert [r["recorded_at"] for r in recordings] == [
            "2026-09-22T23:00:00",
            "2026-09-23T06:00:00",
        ]

    def test_scan_of_empty_root_returns_empty_list(self, tmp_path):
        result = runner.invoke(jpr_recordings.app, ["scan", "--root", str(tmp_path)])

        assert result.exit_code == 0
        assert json.loads(result.stdout) == []

    def test_scan_of_nonexistent_root_returns_empty_list(self, tmp_path):
        result = runner.invoke(jpr_recordings.app, ["scan", "--root", str(tmp_path / "does-not-exist")])

        assert result.exit_code == 0
        assert json.loads(result.stdout) == []

    def test_unreadable_when_path_cannot_be_read(self, tmp_path):
        # A directory named like a recording can't be read as bytes.
        day_dir = tmp_path / "2026-09-23"
        day_dir.mkdir()
        (day_dir / "06-34-10.m4a").mkdir()

        result = runner.invoke(jpr_recordings.app, ["scan", "--root", str(tmp_path)])

        (recording,) = json.loads(result.stdout)
        assert recording["status"] == "unreadable"
        assert recording["detail"]


class TestPlaceholderMaterialization:
    def test_placeholder_materializes_and_becomes_ready(self, tmp_path, monkeypatch):
        install_fake_brctl(monkeypatch, tmp_path, payload=b"prefix" + jpr_blob("materialized"))
        monkeypatch.setattr(jpr_recordings.time, "sleep", lambda _seconds: None)
        day_dir = tmp_path / "2026-09-23"
        day_dir.mkdir()
        (day_dir / ".06-34-10.m4a.icloud").write_bytes(b"")

        result = runner.invoke(jpr_recordings.app, ["scan", "--root", str(tmp_path), "--timeout", "5"])

        (recording,) = json.loads(result.stdout)
        assert recording["status"] == "ready"
        assert recording["transcript"] == "materialized"
        assert recording["path"].endswith("2026-09-23/06-34-10.m4a")

    def test_placeholder_that_never_arrives_is_reported_as_downloading(self, tmp_path, monkeypatch):
        install_fake_brctl(monkeypatch, tmp_path, payload=None)
        monkeypatch.setattr(jpr_recordings.time, "sleep", lambda _seconds: None)
        day_dir = tmp_path / "2026-09-23"
        day_dir.mkdir()
        (day_dir / ".06-34-10.m4a.icloud").write_bytes(b"")

        result = runner.invoke(jpr_recordings.app, ["scan", "--root", str(tmp_path), "--timeout", "0.05"])

        (recording,) = json.loads(result.stdout)
        assert recording["status"] == "downloading"
        assert not (day_dir / "06-34-10.m4a").exists()


class TestDelete:
    def test_deletes_a_ready_recording(self, tmp_path):
        path = make_recording(tmp_path, "2026-09-23", "06-34-10", b"prefix" + jpr_blob("bye"))

        result = runner.invoke(jpr_recordings.app, ["delete", str(path), "--root", str(tmp_path)])

        assert result.exit_code == 0
        assert not path.exists()

    def test_deletes_a_related_group_together(self, tmp_path):
        first = make_recording(tmp_path, "2026-09-23", "06-00-00", b"prefix" + jpr_blob("one"))
        second = make_recording(tmp_path, "2026-09-23", "06-05-00", b"prefix" + jpr_blob("two"))

        result = runner.invoke(jpr_recordings.app, ["delete", str(first), str(second), "--root", str(tmp_path)])

        assert result.exit_code == 0
        assert not first.exists()
        assert not second.exists()

    def test_refuses_untranscribed_recording(self, tmp_path):
        path = make_recording(tmp_path, "2026-09-23", "06-34-10", b"no marker in here")

        result = runner.invoke(jpr_recordings.app, ["delete", str(path), "--root", str(tmp_path)])

        assert result.exit_code != 0
        assert path.exists()

    def test_refuses_path_outside_root(self, tmp_path):
        other_root = tmp_path / "root"
        other_root.mkdir()
        outside = tmp_path / "outside"
        path = make_recording(outside, "2026-09-23", "06-34-10", b"prefix" + jpr_blob("x"))

        result = runner.invoke(jpr_recordings.app, ["delete", str(path), "--root", str(other_root)])

        assert result.exit_code != 0
        assert path.exists()

    def test_refuses_missing_path(self, tmp_path):
        day_dir = tmp_path / "2026-09-23"
        day_dir.mkdir()
        missing = day_dir / "06-34-10.m4a"  # correctly named, but never created

        result = runner.invoke(jpr_recordings.app, ["delete", str(missing), "--root", str(tmp_path)])

        assert result.exit_code != 0

    def test_refuses_non_recording_path(self, tmp_path):
        stray_dir = tmp_path / "2026-09-23"
        stray_dir.mkdir()
        stray = stray_dir / "not-a-recording.txt"
        stray.write_text("oops")

        result = runner.invoke(jpr_recordings.app, ["delete", str(stray), "--root", str(tmp_path)])

        assert result.exit_code != 0
        assert stray.exists()

    def test_group_is_all_or_nothing(self, tmp_path):
        good = make_recording(tmp_path, "2026-09-23", "06-00-00", b"prefix" + jpr_blob("good"))
        bad = make_recording(tmp_path, "2026-09-23", "07-00-00", b"no marker in here")

        result = runner.invoke(jpr_recordings.app, ["delete", str(good), str(bad), "--root", str(tmp_path)])

        assert result.exit_code != 0
        assert good.exists(), "a valid recording must survive if its group-mate fails validation"
        assert bad.exists()


class TestGlobalOptions:
    def test_version_flag_prints_version_and_exits_cleanly(self):
        result = runner.invoke(jpr_recordings.app, ["--version"])

        assert result.exit_code == 0
        assert result.stdout.strip() == jpr_recordings.__version__

    def test_log_file_receives_log_output(self, tmp_path):
        log_file = tmp_path / "log.txt"
        day_dir = tmp_path / "2026-09-23"
        day_dir.mkdir()
        (day_dir / ".06-34-10.m4a.icloud").write_bytes(b"")

        result = runner.invoke(
            jpr_recordings.app,
            ["--log-file", str(log_file), "--log-level", "DEBUG", "scan", "--root", str(tmp_path), "--timeout", "0"],
        )

        assert result.exit_code == 0
        assert log_file.exists()
        assert log_file.read_text().strip() != ""


class TestShebangExecution:
    def test_runs_directly_through_its_own_shebang(self):
        result = subprocess.run(
            [str(SCRIPT_PATH), "--version"],
            capture_output=True,
            text=True,
            timeout=120,
        )

        assert result.returncode == 0
        assert result.stdout.strip() == jpr_recordings.__version__
