#!/usr/bin/env -S uv run --no-project --script --quiet
# /// script
# requires-python = ">=3.15"
# dependencies = [
#     "typer",
#     "git-workflow-utils @ git+https://github.com/wolf/git-workflow-utils.git@v1.4.0",
# ]
#
# [tool.uv]
# exclude-newer = "4 days"
# ///
"""
Sync updates from a shared branch into your working branch via cherry-pick.

Typical use case: repos with a shared branch (e.g., 'main' or 'release') and a
local-only branch (e.g., 'local-only' with secrets that should never be pushed).

The shared branch is found automatically: the remote's default branch
(`origin/HEAD`) if known, else the first of release, main, master that exists.
Pass --branch to override.

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

Output: this tool produces no data, only a narrated workflow, so all of its own
messages go to stderr and stdout stays clean (git's own output is passed through).

Example:
    # Pull the shared branch and cherry-pick to current branch (local-only)
    sync-main.py

    # Pull a different branch
    sync-main.py --branch develop

    # Stash uncommitted changes during sync
    sync-main.py --stash

    # Preview what would happen
    sync-main.py --dry-run

"""

from __future__ import annotations

import shlex
import subprocess
from typing import Annotated

import typer
from git_workflow_utils import (
    current_branch,
    fetch_all,
    has_uncommitted_changes,
    run_git,
)

CANDIDATE_BRANCHES = ("release", "main", "master")


class CherryPickConflict(Exception):
    """A cherry-pick stopped and needs the user to resolve or abort it."""


def say(message: str) -> None:
    """Print a progress message to stderr, keeping stdout clean."""
    typer.echo(message, err=True)


def git(*args: str, dry_run: bool, capture: bool = False) -> subprocess.CompletedProcess | None:
    """Run a git command, or only announce it when `dry_run` is set (returning `None`)."""
    if dry_run:
        say(f"[DRY RUN] Would run: git {shlex.join(args)}")
        return None
    return run_git(*args, capture=capture)


def fetch(*, dry_run: bool) -> None:
    """Fetch all remotes, pruning deleted refs and updating tags."""
    if dry_run:
        git("fetch", "--prune", "--all", "--tags", "--recurse-submodules", dry_run=True)
    else:
        fetch_all()


def resolve_shared_branch(requested: str | None = None) -> str:
    """
    Return the name of the shared branch to pull from.

    Resolution order: the explicitly `requested` name; the remote's default
    branch as recorded in `origin/HEAD`; the first of `CANDIDATE_BRANCHES`
    that exists locally or on `origin`.

    Raises `typer.Exit(1)` with a message if nothing can be found.

    """
    if requested:
        return requested

    result = run_git("symbolic-ref", "--short", "refs/remotes/origin/HEAD", capture=True, check=False)
    if result.returncode == 0 and result.stdout.strip().startswith("origin/"):
        return result.stdout.strip().removeprefix("origin/")

    for name in CANDIDATE_BRANCHES:
        for ref in (f"refs/heads/{name}", f"refs/remotes/origin/{name}"):
            if run_git("show-ref", "--verify", "--quiet", ref, check=False).returncode == 0:
                return name

    say(
        f"Error: could not determine the shared branch (no origin/HEAD; none of {', '.join(CANDIDATE_BRANCHES)} exist). "
        "Pass --branch."
    )
    raise typer.Exit(1)


def pull_shared_branch(branch: str, target_branch: str, *, dry_run: bool) -> tuple[str, str]:
    """
    Switch to `branch`, pull it, and switch to `target_branch`.

    Returns the SHAs of `branch` before and after the pull (both empty in a dry run).

    Raises `subprocess.CalledProcessError` if any git step fails.

    """
    say(f"Switching to {branch} to pull updates...")
    git("switch", branch, dry_run=dry_run)
    before = git("rev-parse", branch, dry_run=dry_run, capture=True)
    git("pull", dry_run=dry_run)
    after = git("rev-parse", branch, dry_run=dry_run, capture=True)

    say(f"Switching back to {target_branch}...")
    git("switch", target_branch, dry_run=dry_run)
    return (before.stdout.strip(), after.stdout.strip()) if before and after else ("", "")


def cherry_pick_new_commits(branch: str, target_branch: str, before_sha: str, after_sha: str) -> None:
    """
    Cherry-pick the commits `branch` gained (`before_sha..after_sha`) onto the current branch.

    Commits already on `target_branch` (by patch-id) are skipped.

    Raises `CherryPickConflict` if the cherry-pick stops.

    """
    # `git cherry <upstream> <head> <limit>` checks only <limit>..<head>.
    result = run_git("cherry", "-v", target_branch, after_sha, before_sha, capture=True)
    entries = [line.split(maxsplit=2) for line in result.stdout.strip().splitlines()]
    to_pick = [sha for flag, sha, _ in entries if flag == "+"]
    skipped = len(entries) - len(to_pick)

    if to_pick:
        say(f"Cherry-picking {len(to_pick)} new commit(s) from {branch}...")
        try:
            run_git("cherry-pick", *to_pick)
        except subprocess.CalledProcessError as error:
            raise CherryPickConflict from error

    parts = [f"{len(to_pick)} applied"] if to_pick else []
    parts += [f"{skipped} skipped"] if skipped else []
    say(f"✓ Cherry-pick complete ({', '.join(parts)})")


def recover(original_branch: str, *, stashed: bool) -> None:
    """Best-effort return to `original_branch` and restore the stash after a failed git step."""
    if current_branch() != original_branch:
        run_git("switch", original_branch, check=False)
    if stashed:
        if run_git("stash", "pop", check=False).returncode == 0:
            say("✓ Stashed changes restored")
        else:
            say("Warning: Stashed changes not restored. Run 'git stash pop' manually.")


def main(
    branch: Annotated[
        str | None,
        typer.Option(
            "--branch",
            "-b",
            help="Branch to pull from. Defaults to the remote's default branch (origin/HEAD), else the first of release, main, master that exists.",
        ),
    ] = None,
    target: Annotated[str, typer.Option("--target", "-t", help="Branch to cherry-pick into. Defaults to current branch.")] = "",
    stash: Annotated[bool, typer.Option("--stash", "-s", help="Stash uncommitted changes before syncing and restore after")] = False,
    dry_run: Annotated[bool, typer.Option("--dry-run", "-n", help="Show what would be done without doing it")] = False,
) -> None:
    """
    Pull updates from a shared branch and cherry-pick them into your working branch.

    Saves your current branch, switches to the shared branch (see --branch for
    how it is found), pulls updates, switches back, and cherry-picks any new
    commits that were pulled.

    Exits 1 if a git step fails or a cherry-pick needs manual resolution.

    """
    branch = resolve_shared_branch(branch)
    original_branch = current_branch()
    target_branch = target or original_branch

    # CRITICAL: the stash holds the user's uncommitted work. Every exit below must
    # either restore it or say exactly how to, or that work is silently stranded.
    stashed = stash and has_uncommitted_changes()
    if stashed:
        say("Stashing uncommitted changes...")
        git("stash", "push", "--include-untracked", "--message", "sync-main autostash", dry_run=dry_run)

    try:
        if original_branch == branch:
            say(f"Already on {branch}, fetching and pulling...")
            fetch(dry_run=dry_run)
            git("pull", dry_run=dry_run)
        else:
            say(f"Current branch: {original_branch}")
            say("Fetching all remotes...")
            fetch(dry_run=dry_run)
            before_sha, after_sha = pull_shared_branch(branch, target_branch, dry_run=dry_run)
            if dry_run:
                say(f"[DRY RUN] Would cherry-pick any new commits from {branch}")
            elif before_sha == after_sha:
                say(f"No new commits pulled from {branch}")
            else:
                cherry_pick_new_commits(branch, target_branch, before_sha, after_sha)
    except CherryPickConflict:
        # CRITICAL: the stash is deliberately NOT popped here. Popping it onto a
        # half-applied cherry-pick would mix the user's uncommitted work into the
        # conflict they now have to resolve.
        say("Error: Cherry-pick failed. You may need to resolve conflicts.")
        say("Run 'git cherry-pick --abort' to cancel or resolve conflicts and continue.")
        if stashed:
            say("Warning: Stashed changes not restored due to error. Run 'git stash pop' manually.")
        raise typer.Exit(1) from None
    except subprocess.CalledProcessError as error:
        say(f"Error: `{shlex.join(map(str, error.cmd))}` failed (exit {error.returncode}).")
        recover(original_branch, stashed=stashed)
        raise typer.Exit(1) from error

    if stashed:
        say("Restoring stashed changes...")
        if dry_run:
            git("stash", "pop", dry_run=True)
        else:
            try:
                run_git("stash", "pop")
                say("✓ Stashed changes restored")
            except subprocess.CalledProcessError:
                say("Warning: Failed to restore stashed changes. Run 'git stash pop' manually.")


if __name__ == "__main__":
    typer.run(main)
