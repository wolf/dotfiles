#!/usr/bin/env -S uv run --no-project --script --quiet
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "typer",
#     "typing_extensions",
#     "git-workflow-utils @ git+https://github.com/wolf/git-workflow-utils.git",
# ]
# ///
"""
Create Git worktrees with intelligent branch resolution and automated setup.

This script simplifies the workflow of creating Git worktrees by:
- Automatically finding branches (local or remote) by name
- Creating worktrees in sensible default locations
- Initializing submodules in the new worktree
- Setting up direnv (.envrc → direnv allow, or .envrc.sample → .envrc symlink → direnv allow)

Example:
    # Create worktree for existing branch (finds origin/feature if no local branch)
    make-worktree.py feature

    # Create worktree with specific path
    make-worktree.py feature-branch /path/to/worktree

    # Create new branch starting from a specific ref
    make-worktree.py new-feature --from main
"""
import os
import subprocess
from pathlib import Path
from typing import Optional

import typer
from typing_extensions import Annotated

from git_workflow_utils import (
    current_branch,
    direnv_allow,
    fetch_all,
    find_branches,
    initialize_repo,
    is_absolute_repo_path,
    resolve_path,
    resolve_repo,
    run_git,
    sanitize_directory_name,
    submodule_update,
)


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

    fetch_all(repo=repo, quiet=True)

    remote_prefix = f"{remote_name}/"
    existing_branches = find_branches(new_worktree_branch, repo=repo, remote_name=remote_name)
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
            starting_ref = current_branch(repo=repo)

        extra_arguments = ["-b", new_worktree_branch, starting_ref]

    if not new_worktree:
        new_worktree = Path(sanitize_directory_name(new_worktree_branch))
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
    initialize_repo(new_repo)
    print(str(new_repo))


if __name__ == "__main__":
    typer.run(main)
