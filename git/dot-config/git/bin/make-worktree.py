#!/usr/bin/env -S uv run --no-project --script --quiet
# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "typer",
#     "typing_extensions",
# ]
# ///
import os
import subprocess
from pathlib import Path
from typing import Optional

import typer
from typing_extensions import Annotated


def resolve_path(path: str|Path|None = None) -> Path:
    """
    Convert a path to an absolute, resolved Path object.

    Args:
        path: Path to resolve. If None or empty, uses current working directory.
              Handles tilde expansion for home directory.

    Returns:
        Absolute, resolved Path object.
    """
    if not path:
        # Catches both `None` and the empty string
        path = Path.cwd()
    elif "~" in str(path):
        path = os.path.expanduser(path)
    return Path(path).resolve()


def is_absolute_repo_path(repo: Path) -> bool:
    """
    Return True if `repo` is an absolute path to an actual Git working copy.

    We **don't** check that `repo / ".git"` is a directory (which is only true in the main
    working copy, not in any of its worktrees).

    This is meant to be used in `assert`s.
    """
    return (
        repo.is_absolute()
        and repo.is_dir()
        and (repo / ".git").exists()
    )


def resolve_repo(repo: str|Path|None = None) -> Path:
    """
    Resolve a path to a Git repository and validate it exists.

    Args:
        repo: Path to repository. Uses current directory if not provided.

    Returns:
        Absolute path to the repository.

    Raises:
        AssertionError: If the path doesn't point to a valid Git repository.
    """
    repo = resolve_path(repo)
    assert is_absolute_repo_path(repo)
    return repo


def fetch_all(repo: Path) -> None:
    """
    Bring all **remote** branches up-to-date.

    Pulling would be harder. I'd have to worry about merging/rebasing and/or anything in
    the way.
    """
    assert is_absolute_repo_path(repo)

    # Bring all tags and remote branches up-to-date
    subprocess.run([
        "git",
        "-C", str(repo),
        "fetch",
        "--prune", "--all", "--tags", "--recurse-submodules",
    ], check=True, stdout=subprocess.DEVNULL)


def find_branches(repo: Path, pattern: str) -> list[str]:
    """
    Find all branches (local and remote) matching a pattern.

    Args:
        repo: Path to the Git repository.
        pattern: Branch name pattern to search for. If you specifically want
                a remote branch, use "origin/foo" instead of just "foo".

    Returns:
        List of matching branch names with ref prefixes removed
        (e.g., "main" instead of "refs/heads/main" or "origin/main"
        instead of "refs/remotes/origin/main").
    """
    assert is_absolute_repo_path(repo)
    assert pattern

    subprocess_result = subprocess.run([
        "git",
        "-C", str(repo),
        "branch",
        "--format=%(refname)",
        "--all", "--list",
        pattern,
    ], capture_output=True, text=True, check=True)

    all_matches: list[str] = []
    for match in subprocess_result.stdout.splitlines():
        if not (match := match.strip()):
            continue
        match = match.removeprefix("refs/heads/")
        match = match.removeprefix("refs/remotes/")
        all_matches.append(match)

    return all_matches


def current_branch(repo: Path) -> str:
    """
    Get the currently checked out branch name.

    Args:
        repo: Path to the Git repository.

    Returns:
        Name of the current branch.
    """
    assert is_absolute_repo_path(repo)

    subprocess_result = subprocess.run([
        "git",
        "-C", str(repo),
        "branch",
        "--show-current",
    ], capture_output=True, text=True, check=True)

    return subprocess_result.stdout.strip()


def worktree_add(
    repo: Path,
    new_worktree_branch: str,
    new_worktree: str|Path|None = None,
    starting_ref: str|None = None,
    remote_name: str = "origin",
) -> Path:
    """
    Create a new Git worktree for a branch.

    If the branch already exists (locally or remotely), checks it out.
    If it doesn't exist, creates a new branch starting from starting_ref
    (or the current branch if not specified).

    Args:
        repo: Path to the main Git repository.
        new_worktree_branch: Name of the branch to check out or create.
        new_worktree: Path where the worktree should be created.
                     Defaults to branch name as a sibling directory.
        starting_ref: Starting point for new branches. Defaults to current branch.
        remote_name: Name of the remote to check for existing branches.

    Returns:
        Absolute path to the newly created worktree.
    """
    assert is_absolute_repo_path(repo)
    assert new_worktree_branch

    remote_prefix = f"{remote_name}/"
    existing_branches = find_branches(repo, new_worktree_branch)
    if existing_branches:
        # The branch we want exists. Don't create a new one. Don't specify a starting point.
        local_branches = {b for b in existing_branches if not b.startswith(remote_prefix)}
        remote_branches = {b for b in existing_branches if b not in local_branches}

        assert len(local_branches) <= 1
        assert len(remote_branches) <= 1

        if local_branches:
            new_worktree_branch = local_branches.pop()
        else:
            new_worktree_branch = remote_branches.pop().removeprefix(remote_prefix)

        extra_arguments = [new_worktree_branch]
    else:
        # We need to create a new branch with the supplied name.
        assert not new_worktree_branch.startswith(remote_prefix)

        if not starting_ref:
            starting_ref = current_branch(repo)

        extra_arguments = ["-b", new_worktree_branch, starting_ref]

    if not new_worktree:
        new_worktree = Path(new_worktree_branch)
    new_worktree = Path(new_worktree)

    # Resolve worktree path with intelligent defaults:
    # - Single name (e.g., "feature") -> sibling to main repo
    # - Relative path starting with "../" -> relative to main repo
    # - Otherwise -> use as-is
    if len(new_worktree.parts) == 1:
        new_worktree = repo.parent / new_worktree
    if not new_worktree.is_absolute() and str(new_worktree).startswith("../"):
        new_worktree = repo / new_worktree

    new_worktree = resolve_path(new_worktree)
    assert not new_worktree.exists()

    subprocess.run([
        "git",
        "-C", str(repo),
        "worktree", "add",
        str(new_worktree),
        *extra_arguments,
    ], check=True, stdout=subprocess.DEVNULL)

    return new_worktree


def submodule_update(repo: Path) -> None:
    """
    Update submodules in the repository recursively.

    Args:
        repo: Path to the Git repository.
    """
    assert is_absolute_repo_path(repo)

    subprocess.run([
        "git",
        "-C", str(repo),
        "submodule", "update",
        "--recursive",
    ], check=True, stdout=subprocess.DEVNULL)


def direnv_allow(envrc: Path) -> None:
    """
    Allow direnv to load the specified .envrc file.

    Args:
        envrc: Path to the .envrc file.
    """
    assert envrc.is_file()

    subprocess.run([
        "direnv",
        "allow",
        str(envrc),
    ], check=True, stdout=subprocess.DEVNULL)


def setup_worktree(repo: Path) -> None:
    """Finish anything needed in a new worktree (which isn't much)."""
    assert is_absolute_repo_path(repo)

    submodule_update(repo)

    envrc_sample = (repo / ".envrc.sample").resolve()
    envrc = (repo / ".envrc").resolve()
    if envrc_sample.exists() and not envrc.exists():
        envrc.symlink_to(envrc_sample)
    if envrc.exists():
        # Everything is new in this worktree, whether we symlinked or not
        direnv_allow(envrc)


def main(
    branch: Annotated[str, typer.Argument(help="The name of the branch you are checking out or creating. Will also serve as the new repo name if you don't supply one.")],
    worktree: Annotated[Optional[Path], typer.Argument(help="Path to the new repo. A single name implies a sibling to the starting repo. Otherwise, if relative, starts at the starting repo.")] = None,
    repo: Annotated[Optional[Path], typer.Option("-C", help="The repo to which you are adding a worktree. Uses the repo you are currently **in** if not supplied.")] = None,
    starting_ref: Annotated[Optional[str], typer.Option("--from", "-f", help="When creating a new branch, start it from this commit/branch/tag. Defaults to the current branch of the repo.")] = None,
    remote: Annotated[str, typer.Option(help="In case you need a remote other than origin.")] = "origin",
):
    """
    Create a new Git worktree with intelligent defaults and automated setup.

    This script automates the tedious parts of creating Git worktrees:
    - Resolves branch names (checks local and remote)
    - Creates worktrees in sensible locations
    - Initializes submodules
    - Sets up direnv if .envrc.sample exists
    """
    starting_repo = resolve_repo(repo)
    new_repo = worktree_add(starting_repo, branch, worktree, starting_ref, remote)
    setup_worktree(new_repo)
    print(str(new_repo))


if __name__ == "__main__":
    typer.run(main)
