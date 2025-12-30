import pytest
from pathlib import Path
import subprocess
import importlib.util
import os

# Import make-worktree.py using importlib (can't use regular import due to hyphen)
SCRIPT_PATH = Path(__file__).parent.parent / "make-worktree.py"
spec = importlib.util.spec_from_file_location("make_worktree", SCRIPT_PATH)
make_worktree = importlib.util.module_from_spec(spec)
spec.loader.exec_module(make_worktree)

# Extract functions for easier access
resolve_path = make_worktree.resolve_path
is_absolute_repo_path = make_worktree.is_absolute_repo_path


def run_script_with_coverage(args, **kwargs):
    """
    Run the script via coverage to track subprocess execution.

    Args:
        args: List of arguments to pass to the script (don't include script path)
        **kwargs: Additional arguments to pass to subprocess.run()

    Returns:
        subprocess.CompletedProcess result
    """
    import sys

    # Run script through coverage using the same Python interpreter
    cmd = [
        sys.executable, "-m", "coverage", "run",
        "--parallel-mode",  # Create separate .coverage.* files
        "--source=.",       # Track coverage for current directory
        str(SCRIPT_PATH),
        *args
    ]
    return subprocess.run(cmd, **kwargs)


def test_resolve_path_current_dir():
    """Test that resolve_path with no argument returns current directory."""
    result = resolve_path(None)
    assert result == Path.cwd()
    assert result.is_absolute()


def test_resolve_path_empty_string():
    """Test that resolve_path with empty string returns current directory."""
    result = resolve_path("")
    assert result == Path.cwd()
    assert result.is_absolute()


def test_resolve_path_with_tilde(tmp_path, monkeypatch):
    """Test that resolve_path expands tilde to home directory."""
    monkeypatch.setenv("HOME", str(tmp_path))
    result = resolve_path("~/test")
    assert result == tmp_path / "test"


def test_resolve_path_absolute():
    """Test that resolve_path handles absolute paths correctly."""
    test_path = Path("/tmp/test")
    result = resolve_path(test_path)
    assert result.is_absolute()
    assert str(result) == str(test_path.resolve())


def test_is_absolute_repo_path_not_absolute():
    """Test that is_absolute_repo_path returns False for relative paths."""
    assert not is_absolute_repo_path(Path("relative/path"))


def test_is_absolute_repo_path_not_directory(tmp_path):
    """Test that is_absolute_repo_path returns False for non-directories."""
    test_file = tmp_path / "test.txt"
    test_file.touch()
    assert not is_absolute_repo_path(test_file)


def test_is_absolute_repo_path_no_git(tmp_path):
    """Test that is_absolute_repo_path returns False when .git doesn't exist."""
    assert not is_absolute_repo_path(tmp_path)


def test_is_absolute_repo_path_valid(tmp_path):
    """Test that is_absolute_repo_path returns True for valid git repo."""
    git_dir = tmp_path / ".git"
    git_dir.mkdir()
    assert is_absolute_repo_path(tmp_path)


# CLI Tests - test the script as users would actually use it

def test_cli_help():
    """Test that --help works and shows usage information."""
    result = run_script_with_coverage(
        ["--help"],
        capture_output=True,
        text=True
    )
    assert result.returncode == 0
    assert "Create a new Git worktree" in result.stdout
    assert "branch" in result.stdout.lower()


def test_cli_missing_required_argument():
    """Test that script fails appropriately when required branch argument is missing."""
    result = run_script_with_coverage(
        [],
        capture_output=True,
        text=True
    )
    assert result.returncode != 0
    assert "Missing argument" in result.stderr or "required" in result.stderr.lower()


@pytest.fixture
def git_repo(tmp_path):
    """Create a temporary git repository for testing."""
    repo = tmp_path / "test-repo"
    repo.mkdir()

    # Initialize git repo
    subprocess.run(["git", "init"], cwd=repo, check=True, capture_output=True)
    subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=repo, check=True, capture_output=True)
    subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo, check=True, capture_output=True)

    # Create initial commit
    (repo / "README.md").write_text("# Test Repo\n")
    subprocess.run(["git", "add", "README.md"], cwd=repo, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=repo, check=True, capture_output=True)

    return repo


def test_cli_create_worktree_new_branch(git_repo, tmp_path):
    """Test creating a worktree with a new branch."""
    worktree_path = tmp_path / "feature-branch"

    result = run_script_with_coverage(
        ["-C", str(git_repo), "feature-branch", str(worktree_path)],
        capture_output=True,
        text=True
    )

    # Script should succeed and print the worktree path
    assert result.returncode == 0
    assert str(worktree_path) in result.stdout

    # Worktree should exist and be a git repo
    assert worktree_path.exists()
    assert (worktree_path / ".git").exists()

    # Check that we're on the right branch
    branch_result = subprocess.run(
        ["git", "branch", "--show-current"],
        cwd=worktree_path,
        capture_output=True,
        text=True,
        check=True
    )
    assert branch_result.stdout.strip() == "feature-branch"


def test_cli_create_worktree_sibling_directory(git_repo):
    """Test that worktree defaults to sibling directory when only branch name is given."""
    result = run_script_with_coverage(
        ["-C", str(git_repo), "sibling-test"],
        capture_output=True,
        text=True
    )

    assert result.returncode == 0

    # Should create worktree as sibling to main repo
    expected_worktree = git_repo.parent / "sibling-test"
    assert expected_worktree.exists()
    assert (expected_worktree / ".git").exists()


def test_cli_create_worktree_from_remote_branch(git_repo, tmp_path):
    """Test creating a worktree from a branch that exists only on remote."""
    # Create a branch and push it to a "remote" (another local repo)
    remote_repo = tmp_path / "remote"
    remote_repo.mkdir()
    subprocess.run(["git", "init", "--bare"], cwd=remote_repo, check=True, capture_output=True)

    # Add remote and push main first
    subprocess.run(["git", "remote", "add", "origin", str(remote_repo)], cwd=git_repo, check=True, capture_output=True)
    subprocess.run(["git", "push", "-u", "origin", "main"], cwd=git_repo, check=True, capture_output=True)

    # Create a new branch locally with unique content
    subprocess.run(["git", "checkout", "-b", "remote-only"], cwd=git_repo, check=True, capture_output=True)
    (git_repo / "remote.txt").write_text("remote branch file\n")
    subprocess.run(["git", "add", "remote.txt"], cwd=git_repo, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Add remote file"], cwd=git_repo, check=True, capture_output=True)

    # Push to remote
    subprocess.run(["git", "push", "-u", "origin", "remote-only"], cwd=git_repo, check=True, capture_output=True)

    # Go back to main and delete the local branch (so only remote branch exists)
    subprocess.run(["git", "checkout", "main"], cwd=git_repo, check=True, capture_output=True)
    subprocess.run(["git", "branch", "-D", "remote-only"], cwd=git_repo, check=True, capture_output=True)

    # Verify the remote branch still exists
    branches_result = subprocess.run(
        ["git", "branch", "-r"],
        cwd=git_repo,
        capture_output=True,
        text=True,
        check=True
    )
    assert "origin/remote-only" in branches_result.stdout

    # Now create a worktree from the remote-only branch (script should find origin/remote-only)
    worktree_path = tmp_path / "remote-worktree"
    result = run_script_with_coverage(
        ["-C", str(git_repo), "remote-only", str(worktree_path)],
        capture_output=True,
        text=True
    )

    assert result.returncode == 0, f"Script failed: {result.stderr}"
    assert worktree_path.exists()

    # Verify we're on the right branch (local branch should be created)
    branch_result = subprocess.run(
        ["git", "branch", "--show-current"],
        cwd=worktree_path,
        capture_output=True,
        text=True,
        check=True
    )
    # When checking out origin/remote-only, a local remote-only branch should be created
    assert branch_result.stdout.strip() == "remote-only"

    # Verify the content from the remote branch is present
    assert (worktree_path / "remote.txt").exists(), f"remote.txt missing. Files: {list(worktree_path.iterdir())}"


def test_cli_create_worktree_with_envrc_sample(git_repo, tmp_path):
    """Test that .envrc.sample triggers symlink creation and direnv allow."""
    # Create .envrc.sample in the repo
    envrc_sample = git_repo / ".envrc.sample"
    envrc_sample.write_text("# Sample environment config\nexport TEST_VAR=hello\n")
    subprocess.run(["git", "add", ".envrc.sample"], cwd=git_repo, check=True, capture_output=True)
    subprocess.run(["git", "commit", "-m", "Add .envrc.sample"], cwd=git_repo, check=True, capture_output=True)

    # Create a fake direnv command that logs calls
    fake_bin = tmp_path / "fake_bin"
    fake_bin.mkdir()
    fake_direnv = fake_bin / "direnv"
    fake_direnv.write_text("""#!/bin/bash
# Fake direnv that just succeeds
exit 0
""")
    fake_direnv.chmod(0o755)

    # Create worktree with fake direnv in PATH
    worktree_path = tmp_path / "envrc-test"

    import sys
    env = os.environ.copy()
    env["PATH"] = str(fake_bin) + ":" + env.get("PATH", "")

    # Run script with modified PATH
    cmd = [
        sys.executable, "-m", "coverage", "run",
        "--parallel-mode",
        "--source=.",
        str(SCRIPT_PATH),
        "-C", str(git_repo), "envrc-branch", str(worktree_path)
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, env=env)

    assert result.returncode == 0, f"Script failed: {result.stderr}"
    assert worktree_path.exists()

    # Check that .envrc symlink was created
    envrc = worktree_path / ".envrc"
    assert envrc.exists(), f".envrc not found. Files: {list(worktree_path.iterdir())}"
    assert envrc.is_symlink(), ".envrc should be a symlink"

    # The symlink should point to .envrc.sample (relative path)
    assert envrc.readlink() == Path(".envrc.sample")
