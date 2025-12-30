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
Sync updates from a shared branch into your working branch via cherry-pick.

Typical use case: repos with a shared branch (e.g., 'main') and a local-only
branch (e.g., 'local-only' with secrets that should never be pushed).

This script automates the workflow of:
- Fetching all remotes (prune deleted refs, update tags)
- Switching to the shared branch and pulling updates
- Switching back to your working branch
- Cherry-picking new commits (if any were pulled)

Key features:
- Captures SHAs before/after pull to detect new commits
- Optional --stash to handle uncommitted changes
- Comprehensive fetch before pull (all remotes, tags, prune)
- --dry-run to preview actions

Example:
    # Pull main and cherry-pick to current branch (local-only)
    sync-main.py

    # Pull a different branch
    sync-main.py --branch develop

    # Stash uncommitted changes during sync
    sync-main.py --stash

    # Preview what would happen
    sync-main.py --dry-run
"""
import subprocess
import sys
from pathlib import Path

import typer
from typing_extensions import Annotated

from git_workflow_utils import current_branch, fetch_all, has_uncommitted_changes, run_git


def main(
    branch: Annotated[str, typer.Option("--branch", "-b", help="Branch to pull from (e.g., 'main')")] = "main",
    target: Annotated[str, typer.Option("--target", "-t", help="Branch to cherry-pick into. Defaults to current branch.")] = "",
    stash: Annotated[bool, typer.Option("--stash", "-s", help="Stash uncommitted changes before syncing and restore after")] = False,
    dry_run: Annotated[bool, typer.Option("--dry-run", "-n", help="Show what would be done without doing it")] = False,
) -> None:
    """
    Pull updates from a shared branch and cherry-pick them into your working branch.

    Saves your current branch, switches to the specified branch (default: main),
    pulls updates, switches back, and cherry-picks any new commits that were pulled.
    """
    # Stash if requested and there are uncommitted changes
    stashed = False
    if stash and has_uncommitted_changes():
        typer.echo("Stashing uncommitted changes...")
        if not dry_run:
            run_git("stash", "push", "--include-untracked", "--message", "sync-main autostash")
            stashed = True
        else:
            typer.echo("[DRY RUN] Would run: git stash push --include-untracked --message 'sync-main autostash'")

    # Get current branch
    original_branch = current_branch()
    target_branch = target or original_branch

    # If we're already on the branch to pull, just fetch and pull
    if original_branch == branch:
        typer.echo(f"Already on {branch}, fetching and pulling...")
        if not dry_run:
            fetch_all()
            run_git("pull")
        else:
            typer.echo(f"[DRY RUN] Would run: git fetch --prune --all --tags --recurse-submodules")
            typer.echo(f"[DRY RUN] Would run: git pull")

        # Restore stash if we stashed
        if stashed:
            typer.echo("Restoring stashed changes...")
            if not dry_run:
                run_git("stash", "pop")
            else:
                typer.echo("[DRY RUN] Would run: git stash pop")
        return

    typer.echo(f"Current branch: {original_branch}")
    typer.echo(f"Fetching all remotes...")
    if not dry_run:
        fetch_all()
    else:
        typer.echo(f"[DRY RUN] Would run: git fetch --prune --all --tags --recurse-submodules")

    typer.echo(f"Switching to {branch} to pull updates...")

    # Switch to the branch and capture SHA before pull
    if not dry_run:
        run_git("switch", branch)
        result = run_git("rev-parse", branch, capture=True)
        before_sha = result.stdout.strip()
        run_git("pull")
        result = run_git("rev-parse", branch, capture=True)
        after_sha = result.stdout.strip()
    else:
        typer.echo(f"[DRY RUN] Would run: git switch {branch}")
        typer.echo(f"[DRY RUN] Would run: git rev-parse {branch}")
        typer.echo(f"[DRY RUN] Would run: git pull")
        typer.echo(f"[DRY RUN] Would run: git rev-parse {branch}")
        before_sha = after_sha = ""  # Dummy values for dry-run

    # Check if there are new commits
    if not dry_run and before_sha != after_sha:
        result = run_git("rev-list", "--count", f"{before_sha}..{after_sha}", capture=True)
        commit_count = int(result.stdout.strip())
    else:
        commit_count = 0
        if dry_run:
            typer.echo(f"[DRY RUN] Would check commit count")
        else:
            typer.echo(f"No new commits pulled from {branch}")

    # Switch back to original branch
    typer.echo(f"Switching back to {target_branch}...")
    if not dry_run:
        run_git("switch", target_branch)
    else:
        typer.echo(f"[DRY RUN] Would run: git switch {target_branch}")

    # Cherry-pick if there are new commits
    if dry_run:
        typer.echo(f"[DRY RUN] Would cherry-pick commits from {branch}")
    elif commit_count > 0:
        typer.echo(f"Cherry-picking {commit_count} new commit(s) from {branch}...")
        commit_range = f"{before_sha}..{after_sha}"

        try:
            run_git("cherry-pick", commit_range)
            typer.echo(f"✓ Successfully cherry-picked {commit_count} commit(s)")
        except subprocess.CalledProcessError:
            typer.echo("Error: Cherry-pick failed. You may need to resolve conflicts.", err=True)
            typer.echo("Run 'git cherry-pick --abort' to cancel or resolve conflicts and continue.")
            if stashed:
                typer.echo("Warning: Stashed changes not restored due to error. Run 'git stash pop' manually.", err=True)
            raise typer.Exit(1)

    # Restore stash if we stashed
    if stashed:
        typer.echo("Restoring stashed changes...")
        if not dry_run:
            try:
                run_git("stash", "pop")
                typer.echo("✓ Stashed changes restored")
            except subprocess.CalledProcessError:
                typer.echo("Warning: Failed to restore stashed changes. Run 'git stash pop' manually.", err=True)
        else:
            typer.echo("[DRY RUN] Would run: git stash pop")


if __name__ == "__main__":
    typer.run(main)
