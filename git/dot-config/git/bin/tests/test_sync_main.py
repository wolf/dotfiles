"""Tests for sync-main.py script."""
import importlib.util
import subprocess
from pathlib import Path

import pytest

from conftest import run_script_with_coverage

# Import sync-main.py using importlib (can't use regular import due to hyphen)
SCRIPT_PATH = Path(__file__).parent.parent / "sync-main.py"
spec = importlib.util.spec_from_file_location("sync_main", SCRIPT_PATH)
sync_main = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync_main)

# Extract functions for easier access
run_git = sync_main.run_git
current_branch = sync_main.current_branch
has_uncommitted_changes = sync_main.has_uncommitted_changes
fetch_all = sync_main.fetch_all


# Unit tests for helper functions


def test_run_git_success(git_repo, monkeypatch):
    """Test that run_git executes commands successfully."""
    monkeypatch.chdir(git_repo)
    result = run_git("status", capture=True)
    assert result.returncode == 0
    assert "On branch" in result.stdout


def test_run_git_failure():
    """Test that run_git handles failures appropriately."""
    with pytest.raises(subprocess.CalledProcessError):
        run_git("not-a-real-command", check=True)


def test_current_branch(git_repo, monkeypatch):
    """Test that current_branch returns the active branch."""
    monkeypatch.chdir(git_repo)
    # We should be on main initially
    branch = current_branch()
    assert branch == "main"


def test_has_uncommitted_changes_clean(git_repo, monkeypatch):
    """Test that has_uncommitted_changes returns False for clean repo."""
    monkeypatch.chdir(git_repo)
    assert not has_uncommitted_changes()


def test_has_uncommitted_changes_dirty(git_repo, monkeypatch):
    """Test that has_uncommitted_changes returns True when there are changes."""
    monkeypatch.chdir(git_repo)
    # Create a new file
    (git_repo / "test.txt").write_text("test content\n")

    assert has_uncommitted_changes()


# CLI Tests - Integration tests


def test_cli_help():
    """Test that --help works and shows usage information."""
    result = run_script_with_coverage(
        SCRIPT_PATH,
        ["--help"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0
    assert "Pull updates from a shared branch" in result.stdout
    assert "--branch" in result.stdout
    assert "--stash" in result.stdout
    assert "--dry-run" in result.stdout


def test_cli_dry_run(git_repo_with_remote):
    """Test that --dry-run shows what would be done without doing it."""
    git_repo, remote_repo = git_repo_with_remote

    # Create a local-only branch
    subprocess.run(["git", "checkout", "-b", "local-only"], cwd=git_repo, check=True, capture_output=True)

    # Go back to main, create a commit, and push
    subprocess.run(["git", "checkout", "main"], cwd=git_repo, check=True, capture_output=True)
    (git_repo / "new.txt").write_text("new content\n")
    subprocess.run(["git", "add", "new.txt"], cwd=git_repo, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Add new file"], cwd=git_repo, check=True, capture_output=True)
    subprocess.run(["git", "push"], cwd=git_repo, check=True, capture_output=True)

    # Switch back to local-only
    subprocess.run(["git", "checkout", "local-only"], cwd=git_repo, check=True, capture_output=True)

    # Run sync-main with --dry-run
    result = run_script_with_coverage(
        SCRIPT_PATH,
        ["--dry-run"],
        cwd=git_repo,
        capture_output=True,
        text=True
    )

    assert result.returncode == 0
    assert "[DRY RUN]" in result.stdout
    assert "Would run: git fetch" in result.stdout
    assert "Would run: git switch main" in result.stdout
    assert "Would run: git pull" in result.stdout


def test_sync_main_no_new_commits(git_repo_with_remote):
    """Test that syncing when there are no new commits works correctly."""
    git_repo, remote_repo = git_repo_with_remote

    # Create a local-only branch
    subprocess.run(["git", "checkout", "-b", "local-only"], cwd=git_repo, check=True, capture_output=True)

    # Run sync-main (should find no new commits)
    result = run_script_with_coverage(
        SCRIPT_PATH,
        [],
        cwd=git_repo,
        capture_output=True,
        text=True
    )

    assert result.returncode == 0
    assert "No new commits pulled from main" in result.stdout

    # Should still be on local-only branch
    branch_result = subprocess.run(
        ["git", "branch", "--show-current"],
        cwd=git_repo,
        capture_output=True,
        text=True,
        check=True
    )
    assert branch_result.stdout.strip() == "local-only"


def test_sync_main_with_new_commits(git_repo_with_remote, tmp_path):
    """Test that syncing pulls and cherry-picks new commits."""
    git_repo, remote_repo = git_repo_with_remote

    # Create a local-only branch
    subprocess.run(["git", "checkout", "-b", "local-only"], cwd=git_repo, check=True, capture_output=True)

    # Clone the repo to simulate another developer
    other_dev = tmp_path / "other-dev"
    subprocess.run(
        ["git", "clone", str(remote_repo), str(other_dev)],
        check=True,
        capture_output=True
    )
    subprocess.run(["git", "config", "user.email", "other@example.com"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Other Dev"], cwd=other_dev, check=True, capture_output=True)

    # Other dev creates a commit and pushes
    (other_dev / "new.txt").write_text("new content\n")
    subprocess.run(["git", "add", "new.txt"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Add new file"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "push"], cwd=other_dev, check=True, capture_output=True)

    # Now run sync-main on our repo
    result = run_script_with_coverage(
        SCRIPT_PATH,
        [],
        cwd=git_repo,
        capture_output=True,
        text=True
    )

    assert result.returncode == 0
    assert "Fetching all remotes" in result.stdout
    assert "Switching to main" in result.stdout
    assert "Switching back to local-only" in result.stdout
    assert "Cherry-picking 1 new commit(s)" in result.stdout
    assert "Successfully cherry-picked" in result.stdout

    # Should still be on local-only branch
    branch_result = subprocess.run(
        ["git", "branch", "--show-current"],
        cwd=git_repo,
        capture_output=True,
        text=True,
        check=True
    )
    assert branch_result.stdout.strip() == "local-only"

    # The new file should exist
    assert (git_repo / "new.txt").exists()
    assert (git_repo / "new.txt").read_text() == "new content\n"


def test_sync_main_with_multiple_commits(git_repo_with_remote, tmp_path):
    """Test that syncing handles multiple commits correctly."""
    git_repo, remote_repo = git_repo_with_remote

    # Create a local-only branch
    subprocess.run(["git", "checkout", "-b", "local-only"], cwd=git_repo, check=True, capture_output=True)

    # Clone the repo to simulate another developer
    other_dev = tmp_path / "other-dev"
    subprocess.run(
        ["git", "clone", str(remote_repo), str(other_dev)],
        check=True,
        capture_output=True
    )
    subprocess.run(["git", "config", "user.email", "other@example.com"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Other Dev"], cwd=other_dev, check=True, capture_output=True)

    # Other dev creates multiple commits
    (other_dev / "file1.txt").write_text("content 1\n")
    subprocess.run(["git", "add", "file1.txt"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Add file1"], cwd=other_dev, check=True, capture_output=True)

    (other_dev / "file2.txt").write_text("content 2\n")
    subprocess.run(["git", "add", "file2.txt"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Add file2"], cwd=other_dev, check=True, capture_output=True)

    subprocess.run(["git", "push"], cwd=other_dev, check=True, capture_output=True)

    # Now run sync-main
    result = run_script_with_coverage(
        SCRIPT_PATH,
        [],
        cwd=git_repo,
        capture_output=True,
        text=True
    )

    assert result.returncode == 0
    assert "Cherry-picking 2 new commit(s)" in result.stdout
    assert "Successfully cherry-picked" in result.stdout

    # Both files should exist
    assert (git_repo / "file1.txt").exists()
    assert (git_repo / "file2.txt").exists()


def test_sync_main_already_on_main(git_repo_with_remote, tmp_path):
    """Test that syncing when already on main branch works correctly."""
    git_repo, remote_repo = git_repo_with_remote

    # Clone the repo to simulate another developer
    other_dev = tmp_path / "other-dev"
    subprocess.run(
        ["git", "clone", str(remote_repo), str(other_dev)],
        check=True,
        capture_output=True
    )
    subprocess.run(["git", "config", "user.email", "other@example.com"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Other Dev"], cwd=other_dev, check=True, capture_output=True)

    # Other dev creates a commit and pushes
    (other_dev / "new.txt").write_text("new content\n")
    subprocess.run(["git", "add", "new.txt"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Add new file"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "push"], cwd=other_dev, check=True, capture_output=True)

    # We're already on main, just run sync-main
    result = run_script_with_coverage(
        SCRIPT_PATH,
        [],
        cwd=git_repo,
        capture_output=True,
        text=True
    )

    assert result.returncode == 0
    assert "Already on main" in result.stdout
    assert "fetching and pulling" in result.stdout

    # Should still be on main branch
    branch_result = subprocess.run(
        ["git", "branch", "--show-current"],
        cwd=git_repo,
        capture_output=True,
        text=True,
        check=True
    )
    assert branch_result.stdout.strip() == "main"

    # The new file should exist
    assert (git_repo / "new.txt").exists()


def test_sync_main_with_stash(git_repo_with_remote, tmp_path):
    """Test that --stash option handles uncommitted changes."""
    git_repo, remote_repo = git_repo_with_remote

    # Create a local-only branch
    subprocess.run(["git", "checkout", "-b", "local-only"], cwd=git_repo, check=True, capture_output=True)

    # Create uncommitted changes
    (git_repo / "uncommitted.txt").write_text("uncommitted work\n")

    # Clone the repo to simulate another developer
    other_dev = tmp_path / "other-dev"
    subprocess.run(
        ["git", "clone", str(remote_repo), str(other_dev)],
        check=True,
        capture_output=True
    )
    subprocess.run(["git", "config", "user.email", "other@example.com"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Other Dev"], cwd=other_dev, check=True, capture_output=True)

    # Other dev creates a commit and pushes
    (other_dev / "new.txt").write_text("new content\n")
    subprocess.run(["git", "add", "new.txt"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Add new file"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "push"], cwd=other_dev, check=True, capture_output=True)

    # Run sync-main with --stash
    result = run_script_with_coverage(
        SCRIPT_PATH,
        ["--stash"],
        cwd=git_repo,
        capture_output=True,
        text=True
    )

    assert result.returncode == 0
    assert "Stashing uncommitted changes" in result.stdout
    assert "Successfully cherry-picked" in result.stdout
    assert "Restoring stashed changes" in result.stdout
    assert "Stashed changes restored" in result.stdout

    # The uncommitted file should still exist
    assert (git_repo / "uncommitted.txt").exists()
    assert (git_repo / "uncommitted.txt").read_text() == "uncommitted work\n"

    # The new file from main should also exist
    assert (git_repo / "new.txt").exists()


def test_sync_main_different_branch_name(git_repo_with_remote, tmp_path):
    """Test syncing from a branch other than main."""
    git_repo, remote_repo = git_repo_with_remote

    # Create a develop branch and push it
    subprocess.run(["git", "checkout", "-b", "develop"], cwd=git_repo, check=True, capture_output=True)
    (git_repo / "develop.txt").write_text("develop content\n")
    subprocess.run(["git", "add", "develop.txt"], cwd=git_repo, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Add develop file"], cwd=git_repo, check=True, capture_output=True)
    subprocess.run(["git", "push", "-u", "origin", "develop"], cwd=git_repo, check=True, capture_output=True)

    # Create a feature branch
    subprocess.run(["git", "checkout", "-b", "feature"], cwd=git_repo, check=True, capture_output=True)

    # Clone the repo to simulate another developer
    other_dev = tmp_path / "other-dev"
    subprocess.run(
        ["git", "clone", str(remote_repo), str(other_dev)],
        check=True,
        capture_output=True
    )
    subprocess.run(["git", "config", "user.email", "other@example.com"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Other Dev"], cwd=other_dev, check=True, capture_output=True)

    # Other dev modifies develop and pushes
    subprocess.run(["git", "checkout", "develop"], cwd=other_dev, check=True, capture_output=True)
    (other_dev / "new-develop.txt").write_text("new develop content\n")
    subprocess.run(["git", "add", "new-develop.txt"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Add new develop file"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "push"], cwd=other_dev, check=True, capture_output=True)

    # Sync from develop
    result = run_script_with_coverage(
        SCRIPT_PATH,
        ["--branch", "develop"],
        cwd=git_repo,
        capture_output=True,
        text=True
    )

    assert result.returncode == 0
    assert "Switching to develop" in result.stdout
    assert "Successfully cherry-picked" in result.stdout

    # The new file should exist in feature branch
    assert (git_repo / "new-develop.txt").exists()


def test_sync_main_run_twice_no_duplicates(git_repo_with_remote, tmp_path):
    """Test that running sync-main twice doesn't cherry-pick commits twice."""
    git_repo, remote_repo = git_repo_with_remote

    # Create a local-only branch
    subprocess.run(["git", "checkout", "-b", "local-only"], cwd=git_repo, check=True, capture_output=True)

    # Clone the repo to simulate another developer
    other_dev = tmp_path / "other-dev"
    subprocess.run(
        ["git", "clone", str(remote_repo), str(other_dev)],
        check=True,
        capture_output=True
    )
    subprocess.run(["git", "config", "user.email", "other@example.com"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Other Dev"], cwd=other_dev, check=True, capture_output=True)

    # Other dev creates a commit and pushes
    (other_dev / "new.txt").write_text("new content\n")
    subprocess.run(["git", "add", "new.txt"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Add new file"], cwd=other_dev, check=True, capture_output=True)
    subprocess.run(["git", "push"], cwd=other_dev, check=True, capture_output=True)

    # First sync
    result1 = run_script_with_coverage(
        SCRIPT_PATH,
        [],
        cwd=git_repo,
        capture_output=True,
        text=True
    )
    assert result1.returncode == 0
    assert "Cherry-picking 1 new commit(s)" in result1.stdout

    # Get the commit count before second sync
    log_result = subprocess.run(
        ["git", "log", "--oneline"],
        cwd=git_repo,
        capture_output=True,
        text=True,
        check=True
    )
    commit_count_before = len(log_result.stdout.strip().split("\n"))

    # Second sync (no new commits on main)
    result2 = run_script_with_coverage(
        SCRIPT_PATH,
        [],
        cwd=git_repo,
        capture_output=True,
        text=True
    )
    assert result2.returncode == 0
    assert "No new commits pulled from main" in result2.stdout

    # Commit count should be the same (no duplicate cherry-picks)
    log_result = subprocess.run(
        ["git", "log", "--oneline"],
        cwd=git_repo,
        capture_output=True,
        text=True,
        check=True
    )
    commit_count_after = len(log_result.stdout.strip().split("\n"))
    assert commit_count_before == commit_count_after
