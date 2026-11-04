#!/usr/bin/env -S uv run --no-project --script --quiet
# /// script
# requires-python = ">=3.15"
# dependencies = [
#     "pytest",
#     "typer",
#     "git-workflow-utils @ git+https://github.com/wolf/git-workflow-utils.git@v1.4.0",
# ]
#
# [tool.uv]
# exclude-newer = "4 days"
# ///
"""
Tests for sync-main.py, written as promises about what the user ends up with.

Standalone: run it directly (`./test_sync_main.py`) or through pytest. Each test
builds its own throwaway repositories under `tmp_path`.

"""

from __future__ import annotations

import importlib.util
import itertools
import subprocess
import sys
from collections.abc import Callable
from pathlib import Path

import pytest
import typer
from git_workflow_utils import current_branch, run_git

SCRIPT = Path(__file__).resolve().parent.parent / "sync-main.py"
_spec = importlib.util.spec_from_file_location("sync_main", SCRIPT)
assert _spec is not None
assert _spec.loader is not None
sync_main = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(sync_main)
main = sync_main.main
resolve_shared_branch = sync_main.resolve_shared_branch


# Fixtures and helpers


def git(*args: str, repo: Path | None = None) -> str:
    """Return the stripped stdout of a git command."""
    return run_git(*args, repo=repo, capture=True).stdout.strip()


def _identify(repo: Path) -> None:
    """Give `repo` a committer identity, so tests never depend on the machine's git config."""
    run_git("config", "user.email", "test@example.com", repo=repo)
    run_git("config", "user.name", "Test User", repo=repo)


@pytest.fixture
def local_repo(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Path:
    """A repo on branch `main` with one commit and no remote; the current directory."""
    path = tmp_path / "work"
    path.mkdir()
    run_git("init", "--quiet", "-b", "main", repo=path)
    _identify(path)
    (path / "README.md").write_text("# Test Repo\n")
    run_git("add", "README.md", repo=path)
    run_git("commit", "--quiet", "-m", "Initial commit", repo=path)
    monkeypatch.chdir(path)
    return path


@pytest.fixture
def remote(tmp_path: Path) -> Path:
    """An empty bare repository to act as `origin`."""
    path = tmp_path / "remote.git"
    run_git("init", "--quiet", "--bare", "-b", "main", str(path))
    return path


@pytest.fixture
def work(local_repo: Path, remote: Path) -> Path:
    """`local_repo` wired to `remote` the way a clone is, with `main` pushed and `origin/HEAD` set."""
    run_git("remote", "add", "origin", str(remote), repo=local_repo)
    run_git("push", "--quiet", "-u", "origin", "main", repo=local_repo)
    run_git("remote", "set-head", "origin", "main", repo=local_repo)
    return local_repo


@pytest.fixture
def local_only(work: Path) -> Path:
    """`work`, switched to a `local-only` branch like the one this tool exists to serve."""
    run_git("switch", "--quiet", "-c", "local-only", repo=work)
    return work


@pytest.fixture
def push_upstream(tmp_path: Path, remote: Path) -> Callable[..., None]:
    """Return a function that, as another developer, pushes one commit per named file."""
    clones = itertools.count()

    def push(*names: str, branch: str = "main") -> None:
        clone = tmp_path / f"upstream-{next(clones)}"
        run_git("clone", "--quiet", "--branch", branch, str(remote), str(clone))
        _identify(clone)
        for name in names:
            (clone / name).write_text(f"{name} from upstream\n")
            run_git("add", name, repo=clone)
            run_git("commit", "--quiet", "-m", f"Add {name}", repo=clone)
        run_git("push", "--quiet", "origin", branch, repo=clone)

    return push


# Syncing


class TestSync:
    """Promise: new commits on the shared branch arrive on your branch, and you keep your place."""

    @pytest.mark.parametrize("names", [("new.txt",), ("a.txt", "b.txt")])
    def test_new_commits_land_on_the_working_branch(self, local_only, push_upstream, capsys, names):
        """Every upstream commit is applied, and you end on the branch you started on."""
        push_upstream(*names)

        main()

        assert current_branch() == "local-only"
        for name in names:
            assert (local_only / name).read_text() == f"{name} from upstream\n"
        assert f"Cherry-pick complete ({len(names)} applied)" in capsys.readouterr().err

    def test_nothing_new_changes_nothing(self, local_only, capsys):
        """With no upstream change the branch tip does not move."""
        before = git("rev-parse", "HEAD")

        main()

        assert git("rev-parse", "HEAD") == before
        assert "No new commits pulled from main" in capsys.readouterr().err

    def test_running_twice_does_not_duplicate(self, local_only, push_upstream):
        """A second run after a sync finds nothing to apply."""
        push_upstream("new.txt")
        main()
        after_first = git("rev-parse", "HEAD")

        main()

        assert git("rev-parse", "HEAD") == after_first

    def test_commit_already_present_is_skipped(self, local_only, push_upstream, capsys):
        """A change you already carry (same patch, different commit) is not applied twice."""
        (local_only / "new.txt").write_text("new.txt from upstream\n")
        run_git("add", "new.txt", repo=local_only)
        run_git("commit", "--quiet", "-m", "Same change, made locally", repo=local_only)
        before = git("rev-parse", "HEAD")
        push_upstream("new.txt")

        main()

        assert git("rev-parse", "HEAD") == before
        assert "Cherry-pick complete (1 skipped)" in capsys.readouterr().err

    def test_already_on_the_shared_branch_just_pulls(self, work, push_upstream, capsys):
        """On the shared branch itself there is nothing to cherry-pick; it is simply updated."""
        push_upstream("new.txt")

        main()

        assert (work / "new.txt").exists()
        err = capsys.readouterr().err
        assert "Already on main" in err
        assert "Cherry-pick" not in err

    def test_explicit_shared_branch(self, work, push_upstream):
        """`--branch` syncs from that branch instead of the default."""
        run_git("switch", "--quiet", "-c", "develop", repo=work)
        run_git("push", "--quiet", "-u", "origin", "develop", repo=work)
        run_git("switch", "--quiet", "-c", "feature", repo=work)
        push_upstream("develop-only.txt", branch="develop")

        main(branch="develop")

        assert (work / "develop-only.txt").exists()

    def test_explicit_target_receives_the_commits(self, work, push_upstream):
        """`--target` cherry-picks into that branch rather than the current one."""
        run_git("switch", "--quiet", "-c", "feature", repo=work)
        run_git("switch", "--quiet", "-c", "elsewhere", repo=work)
        push_upstream("new.txt")

        main(target="feature")

        assert git("show", "feature:new.txt") == "new.txt from upstream"

    def test_follows_origin_head(self, work, capsys):
        """The shared branch is whatever `origin/HEAD` names, not a hardcoded `main`."""
        run_git("branch", "release", repo=work)
        run_git("push", "--quiet", "origin", "release", repo=work)
        run_git("remote", "set-head", "origin", "release", repo=work)
        run_git("switch", "--quiet", "-c", "local-only", repo=work)

        main(dry_run=True)

        assert "Would run: git switch release" in capsys.readouterr().err


class TestStash:
    """Promise: with `--stash`, your uncommitted work comes through a sync untouched."""

    def test_uncommitted_work_survives(self, local_only, push_upstream, capsys):
        """Untracked work is set aside, the sync happens, and the work comes back."""
        (local_only / "uncommitted.txt").write_text("precious\n")
        push_upstream("new.txt")

        main(stash=True)

        assert (local_only / "uncommitted.txt").read_text() == "precious\n"
        assert (local_only / "new.txt").exists()
        assert git("stash", "list") == ""
        assert "Stashed changes restored" in capsys.readouterr().err

    def test_nothing_to_stash_stashes_nothing(self, local_only, capsys):
        """A clean tree is not stashed."""
        main(stash=True)

        assert "Stashing" not in capsys.readouterr().err
        assert git("stash", "list") == ""

    def test_failed_fetch_restores_the_stash(self, local_only, remote, tmp_path):
        """If the remote is unreachable the work comes back and the exit is a clean 1."""
        (local_only / "uncommitted.txt").write_text("precious\n")
        remote.rename(tmp_path / "remote-gone")

        with pytest.raises(typer.Exit) as raised:
            main(stash=True)

        assert raised.value.exit_code == 1
        assert (local_only / "uncommitted.txt").read_text() == "precious\n"
        assert git("stash", "list") == ""

    def test_failed_pull_returns_you_to_your_branch_with_your_work(self, local_only, push_upstream, capsys):
        """A pull that cannot fast-forward leaves you where you started, stash restored."""
        run_git("config", "pull.ff", "only", repo=local_only)
        run_git("switch", "--quiet", "main", repo=local_only)
        (local_only / "diverged.txt").write_text("unpushed\n")
        run_git("add", "diverged.txt", repo=local_only)
        run_git("commit", "--quiet", "-m", "Unpushed local commit on main", repo=local_only)
        run_git("switch", "--quiet", "local-only", repo=local_only)
        (local_only / "uncommitted.txt").write_text("precious\n")
        push_upstream("new.txt")

        with pytest.raises(typer.Exit) as raised:
            main(stash=True)

        assert raised.value.exit_code == 1
        assert current_branch() == "local-only"
        assert (local_only / "uncommitted.txt").read_text() == "precious\n"
        assert git("stash", "list") == ""
        err = capsys.readouterr().err
        assert "failed (exit" in err
        assert "Traceback" not in err

    def test_conflict_keeps_the_stash_and_says_how_to_get_it(self, local_only, push_upstream, capsys):
        """On a cherry-pick conflict the stash is deliberately left alone, and the user is told."""
        (local_only / "conflict.txt").write_text("local version\n")
        run_git("add", "conflict.txt", repo=local_only)
        run_git("commit", "--quiet", "-m", "Local change", repo=local_only)
        (local_only / "uncommitted.txt").write_text("precious\n")
        push_upstream("conflict.txt")

        with pytest.raises(typer.Exit) as raised:
            main(stash=True)

        assert raised.value.exit_code == 1
        assert git("stash", "list") != ""
        err = capsys.readouterr().err
        assert "Cherry-pick failed" in err
        assert "git stash pop" in err


class TestConflict:
    """Promise: a cherry-pick that cannot apply stops cleanly and tells you what to do."""

    def test_conflict_exits_1_with_instructions(self, local_only, push_upstream, capsys):
        """The exit is a clean 1 and the cherry-pick is left for the user to resolve or abort."""
        (local_only / "conflict.txt").write_text("local version\n")
        run_git("add", "conflict.txt", repo=local_only)
        run_git("commit", "--quiet", "-m", "Local change", repo=local_only)
        push_upstream("conflict.txt")

        with pytest.raises(typer.Exit) as raised:
            main()

        assert raised.value.exit_code == 1
        assert "git cherry-pick --abort" in capsys.readouterr().err
        assert (local_only / ".git" / "CHERRY_PICK_HEAD").exists()


class TestDryRun:
    """Promise: `--dry-run` shows the plan and changes nothing."""

    def test_nothing_changes_and_the_plan_is_shown(self, local_only, push_upstream, capsys):
        """Branch, tip, working tree and stash are all as they were; the planned commands are printed."""
        (local_only / "uncommitted.txt").write_text("precious\n")
        push_upstream("new.txt")
        before = git("rev-parse", "HEAD")

        main(stash=True, dry_run=True)

        assert current_branch() == "local-only"
        assert git("rev-parse", "HEAD") == before
        assert (local_only / "uncommitted.txt").read_text() == "precious\n"
        assert not (local_only / "new.txt").exists()
        assert git("stash", "list") == ""
        err = capsys.readouterr().err
        for planned in (
            "Would run: git stash push --include-untracked --message 'sync-main autostash'",
            "Would run: git fetch",
            "Would run: git switch main",
            "Would run: git pull",
            "Would run: git stash pop",
        ):
            assert planned in err


class TestOutputStreams:
    """Promise: the tool's own messages go to stderr; stdout stays clean for pipes."""

    def test_our_messages_are_not_on_stdout(self, local_only, push_upstream, capfd):
        """Narration appears on stderr only (git's own output may appear on stdout)."""
        push_upstream("new.txt")

        main()

        out, err = capfd.readouterr()
        assert "Cherry-pick complete" in err
        for ours in ("Fetching all remotes", "Switching to", "Cherry-pick"):
            assert ours not in out


# Finding the shared branch


class TestResolveSharedBranch:
    """Promise: the shared branch is found without the caller naming it."""

    def test_explicit_request_wins(self, work):
        """An explicit name is returned as given, even if it doesn't exist."""
        assert resolve_shared_branch("develop") == "develop"

    def test_follows_origin_head(self, work):
        """The remote's default branch beats the candidate list."""
        run_git("branch", "trunk", repo=work)
        run_git("push", "--quiet", "origin", "trunk", repo=work)
        run_git("branch", "release", repo=work)
        run_git("remote", "set-head", "origin", "trunk", repo=work)

        assert resolve_shared_branch() == "trunk"

    def test_falls_back_to_first_candidate_in_list_order(self, local_repo):
        """Without origin/HEAD, the first candidate that exists is used, in list order."""
        assert resolve_shared_branch() == "main"
        run_git("branch", "release", repo=local_repo)
        assert resolve_shared_branch() == "release"

    def test_fallback_sees_a_remote_only_branch(self, local_repo):
        """A candidate that exists only as `origin/<name>` counts."""
        run_git("branch", "-m", "main", "work", repo=local_repo)
        run_git("update-ref", "refs/remotes/origin/master", "HEAD", repo=local_repo)

        assert resolve_shared_branch() == "master"

    def test_no_candidate_is_an_error(self, local_repo, capsys):
        """With nothing to go on, exit 1 and tell the user to pass --branch."""
        run_git("branch", "-m", "main", "work", repo=local_repo)

        with pytest.raises(typer.Exit) as raised:
            resolve_shared_branch()

        assert raised.value.exit_code == 1
        assert "--branch" in capsys.readouterr().err


# The script as a user runs it


class TestCommandLine:
    """Promise: the script runs as `./sync-main.py` through its own PEP 723 block."""

    def test_help_lists_the_options(self):
        """`--help` works and names every option."""
        result = subprocess.run([str(SCRIPT), "--help"], capture_output=True, text=True, check=False)

        assert result.returncode == 0
        for option in ("--branch", "--target", "--stash", "--dry-run"):
            assert option in result.stdout

    def test_end_to_end_sync(self, local_only, push_upstream):
        """A real invocation syncs, exits 0, and keeps its narration off stdout."""
        push_upstream("new.txt")

        result = subprocess.run([str(SCRIPT)], cwd=local_only, capture_output=True, text=True, check=False)

        assert result.returncode == 0
        assert (local_only / "new.txt").exists()
        assert "Cherry-pick complete (1 applied)" in result.stderr
        assert "Cherry-pick complete" not in result.stdout


if __name__ == "__main__":
    sys.exit(pytest.main([__file__]))
