"""Shared pytest fixtures and helpers for git script tests."""
import subprocess
import sys
from pathlib import Path
from typing import Any

import pytest

# Add parent directory to path so scripts can import git_shared
_SCRIPT_DIR = Path(__file__).parent.parent
if str(_SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(_SCRIPT_DIR))


def run_script_with_coverage(script_path: Path, args: list[str], **kwargs: Any) -> subprocess.CompletedProcess:
    """
    Run a script via coverage to track subprocess execution.

    Args:
        script_path: Path to the script to run
        args: List of arguments to pass to the script (don't include script path)
        **kwargs: Additional arguments to pass to subprocess.run()

    Returns:
        subprocess.CompletedProcess result
    """
    # Run script through coverage using the same Python interpreter
    cmd = [
        sys.executable,
        "-m",
        "coverage",
        "run",
        "--parallel-mode",  # Create separate .coverage.* files
        "--source=.",  # Track coverage for current directory
        str(script_path),
        *args,
    ]
    return subprocess.run(cmd, **kwargs)


@pytest.fixture
def git_repo(tmp_path):
    """
    Create a temporary git repository for testing.

    Returns:
        Path: Path to the temporary git repository
    """
    repo = tmp_path / "test-repo"
    repo.mkdir()

    # Initialize git repo
    subprocess.run(["git", "init"], cwd=repo, check=True, capture_output=True)
    subprocess.run(
        ["git", "config", "user.email", "test@example.com"],
        cwd=repo,
        check=True,
        capture_output=True,
    )
    subprocess.run(
        ["git", "config", "user.name", "Test User"],
        cwd=repo,
        check=True,
        capture_output=True,
    )

    # Create initial commit
    (repo / "README.md").write_text("# Test Repo\n")
    subprocess.run(["git", "add", "README.md"], cwd=repo, check=True, capture_output=True)
    subprocess.run(
        ["git", "commit", "-m", "Initial commit"],
        cwd=repo,
        check=True,
        capture_output=True,
    )

    return repo


@pytest.fixture
def git_repo_with_remote(tmp_path, git_repo):
    """
    Create a git repository with a remote (bare repo).

    Returns:
        tuple: (main_repo_path, remote_repo_path)
    """
    remote_repo = tmp_path / "remote"
    remote_repo.mkdir()
    subprocess.run(["git", "init", "--bare"], cwd=remote_repo, check=True, capture_output=True)

    # Add remote and push main
    subprocess.run(
        ["git", "remote", "add", "origin", str(remote_repo)],
        cwd=git_repo,
        check=True,
        capture_output=True,
    )
    subprocess.run(
        ["git", "push", "-u", "origin", "main"],
        cwd=git_repo,
        check=True,
        capture_output=True,
    )

    return git_repo, remote_repo
