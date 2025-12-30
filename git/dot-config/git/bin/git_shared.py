"""Shared utilities for git scripts.

This module provides common git operations that can work either on the current
working directory or on a specified repository path.
"""

import shutil
import subprocess
from pathlib import Path
from typing import Any


def run_git(
    *args: str,
    repo: Path | None = None,
    check: bool = True,
    capture: bool = False,
    **kwargs: Any,
) -> subprocess.CompletedProcess:
    """
    Run a git command and return the result.

    Args:
        *args: Git command arguments (e.g., "status", "--porcelain")
        repo: Optional repository path. If None, runs in current directory.
        check: Whether to raise CalledProcessError on non-zero exit (default: True)
        capture: Whether to capture stdout/stderr (default: False)
        **kwargs: Additional arguments to pass to subprocess.run()

    Returns:
        CompletedProcess result

    Example:
        # Run in current directory
        run_git("status", "--short", capture=True)

        # Run in specific repo
        run_git("fetch", "--all", repo=Path("/path/to/repo"))
    """
    cmd = ["git"]

    # Add -C flag if repo is specified
    if repo is not None:
        cmd.extend(["-C", str(repo)])

    cmd.extend(args)

    # Set up capture if requested
    if capture:
        return subprocess.run(
            cmd, capture_output=True, text=True, check=check, **kwargs
        )

    return subprocess.run(cmd, check=check, **kwargs)


def current_branch(repo: Path | None = None) -> str:
    """
    Get the currently checked out branch name.

    Args:
        repo: Optional repository path. If None, uses current directory.

    Returns:
        Name of the current branch

    Example:
        branch = current_branch()
        branch = current_branch(Path("/path/to/repo"))
    """
    result = run_git("branch", "--show-current", repo=repo, capture=True)
    return result.stdout.strip()


def has_uncommitted_changes(repo: Path | None = None) -> bool:
    """
    Check if there are uncommitted changes in the working tree.

    This includes both tracked and untracked files.

    Args:
        repo: Optional repository path. If None, uses current directory.

    Returns:
        True if there are uncommitted changes, False otherwise

    Example:
        if has_uncommitted_changes():
            print("You have uncommitted changes")
    """
    result = run_git("status", "--porcelain", repo=repo, capture=True)
    return bool(result.stdout.strip())


def fetch_all(repo: Path | None = None, *, quiet: bool = False) -> None:
    """
    Fetch all remotes, prune deleted refs, and update tags.

    Args:
        repo: Optional repository path. If None, uses current directory.
        quiet: If True, suppresses output (default: False)

    Example:
        fetch_all()
        fetch_all(Path("/path/to/repo"), quiet=True)
    """
    kwargs = {}
    if quiet:
        kwargs["stdout"] = subprocess.DEVNULL

    run_git(
        "fetch",
        "--prune",
        "--all",
        "--tags",
        "--recurse-submodules",
        repo=repo,
        **kwargs,
    )


def resolve_path(path: str | Path | None = None) -> Path:
    """
    Resolve a path to an absolute Path object.

    Args:
        path: Path to resolve. If None or empty string, returns current directory.

    Returns:
        Absolute Path object

    Example:
        resolve_path("~/projects")  # Returns /home/user/projects
        resolve_path(None)           # Returns current directory
    """
    if not path:
        return Path.cwd()

    return Path(path).expanduser().resolve()


def is_absolute_repo_path(repo: Path) -> bool:
    """
    Check if the given path is an absolute path to a git repository.

    Args:
        repo: Path to check

    Returns:
        True if path is absolute, is a directory, and contains .git

    Example:
        if is_absolute_repo_path(Path("/path/to/repo")):
            print("Valid git repository")
    """
    return (
        repo.is_absolute()
        and repo.is_dir()
        and (repo / ".git").exists()
    )


def resolve_repo(repo: str | Path | None = None) -> Path:
    """
    Resolve a path to a Git repository and validate it exists.

    Args:
        repo: Path to repository. Uses current directory if not provided.

    Returns:
        Absolute path to the repository.

    Raises:
        AssertionError: If the path doesn't point to a valid Git repository.

    Example:
        repo = resolve_repo()  # Current directory
        repo = resolve_repo("~/projects/myrepo")
    """
    repo_path = resolve_path(repo)
    assert is_absolute_repo_path(repo_path)
    return repo_path


def find_branches(
    pattern: str,
    repo: str | Path | None = None,
    remote_name: str = "origin",
) -> list[str]:
    """
    Find all branches (local and remote) matching a pattern.

    For simple names (no wildcards), searches for both local branch and
    remote_name/branch. For patterns with wildcards, passes through to git.
    Returns all matches - caller decides priority.

    Args:
        pattern: Branch name or pattern to search for.
        repo: Path to the Git repository. Defaults to current directory.
        remote_name: Name of the remote to search (default: "origin").

    Returns:
        List of matching branch names with ref prefixes removed
        (e.g., "main" instead of "refs/heads/main" or "origin/main"
        instead of "refs/remotes/origin/main").

    Example:
        branches = find_branches("feature")
        branches = find_branches("feature-*", repo=Path("/path/to/repo"))
    """
    repo_path = resolve_repo(repo)
    assert pattern

    # Check if pattern contains git wildcards
    has_wildcards = bool(set("*?[") & set(pattern))

    if has_wildcards:
        # Pattern search - use as-is
        patterns_to_search = [pattern]
    else:
        # Exact name - search local and remote
        patterns_to_search = [
            pattern,  # Local: feature
            f"{remote_name}/{pattern}",  # Remote: origin/feature
        ]

    all_matches = []
    for search_pattern in patterns_to_search:
        result = run_git(
            "branch",
            "--format=%(refname)",
            "--all",
            "--list",
            search_pattern,
            repo=repo_path,
            capture=True,
        )

        all_matches.extend([
            match.removeprefix("refs/heads/").removeprefix("refs/remotes/")
            for line in result.stdout.splitlines()
            if (match := line.strip())
        ])

    # Remove duplicates while preserving order
    seen = set()
    return [m for m in all_matches if not (m in seen or seen.add(m))]


def submodule_update(repo: str | Path | None = None) -> None:
    """
    Update submodules in the repository recursively.

    Args:
        repo: Path to the Git repository. Defaults to current directory.

    Example:
        submodule_update()
        submodule_update(Path("/path/to/repo"))
    """
    repo_path = resolve_repo(repo)

    run_git(
        "submodule",
        "update",
        "--init",
        "--recursive",
        repo=repo_path,
        stdout=subprocess.DEVNULL,
    )


def is_direnv_available() -> bool:
    """
    Check if direnv command is available in PATH.

    Returns:
        True if direnv is installed and available, False otherwise.

    Example:
        if is_direnv_available():
            setup_envrc()
    """
    return shutil.which("direnv") is not None


def direnv_allow(envrc: Path) -> None:
    """
    Allow direnv to load the specified .envrc file.

    Args:
        envrc: Path to the .envrc file.

    Example:
        direnv_allow(Path("/path/to/repo/.envrc"))
    """
    if envrc.is_file() and envrc.name == ".envrc" and is_direnv_available():
        subprocess.run(
            ["direnv", "allow", str(envrc)],
            check=True,
            stdout=subprocess.DEVNULL,
        )


def setup_envrc(repo: str | Path | None = None) -> None:
    """
    Discover, possibly create, and allow `.envrc`.

    If .envrc.sample exists but .envrc doesn't, creates a symlink.
    Then runs direnv allow if .envrc exists.

    Args:
        repo: Path to the repository. Defaults to current directory.

    Example:
        setup_envrc()
        setup_envrc(Path("/path/to/repo"))
    """
    # Early exit if direnv not available - don't even resolve repo
    if not is_direnv_available():
        return

    repo_path = resolve_repo(repo)

    envrc_sample = repo_path / ".envrc.sample"
    envrc = repo_path / ".envrc"

    if envrc_sample.exists() and not envrc.exists():
        envrc.symlink_to(envrc_sample.name)

    if envrc.exists():
        direnv_allow(envrc)


def initialize_repo(repo: str | Path | None = None) -> None:
    """
    Initialize a working copy (worktree or fresh clone) with standard setup.

    This performs common post-clone/worktree setup tasks:
    - Initialize and update submodules recursively
    - Set up .envrc from .envrc.sample (if present and direnv available)

    Note: This is for working copies, not bare repositories.

    Args:
        repo: Path to the working copy. Defaults to current directory.

    Example:
        initialize_repo()
        initialize_repo(Path("/path/to/new-worktree"))
    """
    repo_path = resolve_repo(repo)

    submodule_update(repo_path)
    setup_envrc(repo_path)
