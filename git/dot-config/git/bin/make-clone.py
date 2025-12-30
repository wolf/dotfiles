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
Clone a Git repository with automated initialization.

This script wraps 'git clone' and adds automated setup:
- Passes through all git clone options transparently
- Initializes submodules in the cloned repository
- Sets up direnv (.envrc) if available
- Prints the absolute path to the cloned directory

IMPORTANT: The repository URL must come first. If providing a target directory,
it must come immediately after the URL, before any git options.

Syntax:
    make-clone.py <repository> [<directory>] [git-options...]

Examples:
    # Clone into directory named after repo
    make-clone.py git@github.com:user/repo.git

    # Clone into specific directory
    make-clone.py git@github.com:user/repo.git my-dir

    # Clone with git options (URL must come first)
    make-clone.py git@github.com:user/repo.git --branch develop

    # Clone with custom directory and git options (directory must be second)
    make-clone.py git@github.com:user/repo.git my-dir --depth 1 --branch main
"""
import subprocess
from pathlib import Path
from typing import Optional
from urllib.parse import urlparse

import typer
from typing_extensions import Annotated

from git_workflow_utils import initialize_repo, resolve_path

app = typer.Typer()

# Standard URL schemes that urlparse can handle
STANDARD_URL_SCHEMES = {'http://', 'https://', 'file://', 'git://', 'ssh://'}


def derive_directory_from_url(url: str) -> str:
    """
    Derive directory name from repository URL like git clone does.

    Examples:
        git@github.com:user/repo.git -> repo
        https://github.com/user/repo.git -> repo
        https://github.com/user/repo -> repo
        file:///path/to/repo.git -> repo
    """
    # Extract URL scheme if present
    scheme = None
    if '://' in url:
        scheme = url.split('://', 1)[0] + '://'

    # Handle SSH format (git@host:path) which isn't a standard URL
    if ':' in url and scheme not in STANDARD_URL_SCHEMES:
        # SSH format: git@github.com:user/repo.git
        path = url.split(':', 1)[1]
    else:
        # Use urlparse for standard URLs
        parsed = urlparse(url)
        path = parsed.path

    # Remove .git suffix if present
    if path.endswith('.git'):
        path = path[:-4]

    # Get the last path component
    return Path(path).name


@app.command(context_settings={
    "allow_extra_args": True,
    "ignore_unknown_options": True,
})
def main(
    ctx: typer.Context,
    repository: Annotated[str, typer.Argument(help="Repository URL to clone (must be first argument)")],
    directory: Annotated[Optional[str], typer.Argument(help="Target directory. If provided, must come immediately after repository URL, before any git options.")] = None,
):
    """
    Clone a Git repository and initialize it with submodules and direnv.

    This command wraps 'git clone' and passes through all git clone options.
    After cloning, it initializes the repository (submodules, direnv) and
    prints the absolute path to stdout (useful for shell functions that cd).

    IMPORTANT: Repository URL must come first. If providing a directory, it must
    come second, before any git options.
    """
    # ctx.args contains all the unknown options that we'll pass to git clone
    git_options = ctx.args

    # Determine the target directory
    target_dir = directory if directory else derive_directory_from_url(repository)

    # Build the git clone command
    # Format: git clone [options] <repository> [<directory>]
    clone_cmd = ['git', 'clone'] + git_options + [repository]
    if directory:
        clone_cmd.append(directory)

    # Run git clone
    try:
        subprocess.run(clone_cmd, check=True)
    except subprocess.CalledProcessError as e:
        typer.echo(f"Error: git clone failed with exit code {e.returncode}", err=True)
        raise typer.Exit(1)

    # Initialize the cloned repository (submodules, direnv)
    clone_path = resolve_path(target_dir)
    initialize_repo(clone_path)

    # Print the absolute path for shell functions to use
    print(str(clone_path))


if __name__ == "__main__":
    app()
