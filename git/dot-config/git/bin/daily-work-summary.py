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
Generate a summary of git commits from today across all repositories.

This script scans all git repositories under $REPOS_DIR and finds commits
authored by you, helping you track your daily accomplishments.

Example:
    # Show commits from today (since midnight)
    daily-work-summary.py

    # Show commits from last 24 hours
    daily-work-summary.py --since "24 hours ago"

    # Show commits since specific time
    daily-work-summary.py --since "2025-12-30 08:00"

    # Skip fetching (faster, but may miss recent remote commits)
    daily-work-summary.py --no-fetch

    # Override author email (default: uses each repo's configured email)
    daily-work-summary.py --author-email "you@example.com"
"""
import os
import subprocess
from pathlib import Path
from typing import Optional

import typer
from typing_extensions import Annotated

from git_workflow_utils import (
    fetch_all,
    filter_repos_by_ignore_file,
    find_git_repos,
    get_commits,
    user_email_in_this_working_copy,
)

app = typer.Typer()


@app.command()
def main(
    since: Annotated[
        str,
        typer.Option(
            help="Time range to search (e.g., 'midnight', '24 hours ago', '2025-12-30 08:00')"
        ),
    ] = "midnight",
    fetch: Annotated[
        bool,
        typer.Option("--fetch/--no-fetch", help="Fetch all remotes before searching"),
    ] = True,
    repos_dir: Annotated[
        Optional[Path],
        typer.Option(help="Root directory to search for repos (default: $REPOS_DIR)"),
    ] = None,
    author_email: Annotated[
        Optional[str],
        typer.Option(help="Override author email (default: use each repo's config)"),
    ] = None,
) -> None:
    """Generate a summary of your git commits from today."""

    # Determine repos directory
    if repos_dir is None:
        repos_dir_str = os.environ.get("REPOS_DIR")
        if not repos_dir_str:
            typer.echo("Error: $REPOS_DIR not set and --repos-dir not provided", err=True)
            raise typer.Exit(1)
        repos_dir = Path(repos_dir_str)

    if not repos_dir.exists():
        typer.echo(f"Error: Directory not found: {repos_dir}", err=True)
        raise typer.Exit(1)

    # Find all repos (excluding worktrees, with .journalignore filtering)
    typer.echo(f"Scanning {repos_dir} for git repositories...")
    all_repos = find_git_repos(repos_dir, include_worktrees=False)
    repos = sorted(filter_repos_by_ignore_file(all_repos, repos_dir, ".journalignore"))
    typer.echo(f"Found {len(repos)} repositories (after filtering)\n")

    # Collect commits from all repos
    all_commits = {}
    for repo in repos:
        if fetch:
            typer.echo(f"Fetching {repo.name}...", nl=False)
            try:
                fetch_all(repo=repo)
                typer.echo(" ✓")
            except subprocess.CalledProcessError:
                typer.echo(" (no remotes)")

        # Get author email for this repo (unless overridden)
        email = author_email or user_email_in_this_working_copy(repo)
        if not email:
            continue

        # Get commits
        commits = list(get_commits(repo=repo, since=since, author_email=email))
        if commits:
            all_commits[repo] = commits

    # Display summary
    typer.echo(f"\n=== Work Summary (since {since}) ===\n")

    if not all_commits:
        typer.echo("No commits found.")
        return

    total_commits = 0
    for repo, commits in all_commits.items():
        typer.echo(f"{repo.name}:")
        for hash_full, summary in commits:
            # Show short hash (first 7 chars)
            typer.echo(f"  {hash_full[:7]} - {summary}")
            total_commits += 1
        typer.echo()

    typer.echo(f"Total: {total_commits} commits across {len(all_commits)} repos")


if __name__ == "__main__":
    app()
