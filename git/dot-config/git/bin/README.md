# Git Utilities

A collection of Python-based git workflow utilities that automate common tasks like worktree management, branch synchronization, and cloning with initialization.

## Overview

These utilities extend git with opinionated workflows for:
- **Worktree management**: Create worktrees with intelligent branch resolution
- **Branch synchronization**: Pull and cherry-pick updates from shared branches
- **Smart cloning**: Clone repositories with automatic submodule and direnv setup

All utilities are written as standalone Python scripts using [uv](https://github.com/astral-sh/uv) for dependency management and can be executed directly.

## Utilities

### make-worktree.py

Create git worktrees with intelligent branch resolution and automated setup.

**Features:**
- Automatically finds branches (local or remote) by name
- Creates worktrees in sensible default locations
- Initializes submodules in the new worktree
- Sets up direnv (.envrc) if available

**Usage:**
```bash
# Create worktree for existing branch (finds origin/feature if no local branch)
make-worktree.py feature

# Create worktree with specific path
make-worktree.py feature-branch /path/to/worktree

# Create new branch starting from a specific ref
make-worktree.py new-feature --from main
```

**Shell wrapper:**
```bash
# Automatically cd into the new worktree
make-worktree feature
```

### sync-main.py

Sync updates from a shared branch into your working branch via cherry-pick.

**Features:**
- Fetches all remotes (prune deleted refs, update tags)
- Switches to the shared branch and pulls updates
- Switches back to your working branch
- Cherry-picks new commits (if any were pulled)
- Optional --stash to handle uncommitted changes
- --dry-run to preview actions

**Usage:**
```bash
# Pull main and cherry-pick to current branch
sync-main.py

# Pull a different branch
sync-main.py --branch develop

# Stash uncommitted changes during sync
sync-main.py --stash

# Preview what would happen
sync-main.py --dry-run

# Sync into a different target branch
sync-main.py --target feature-branch
```

**Typical use case:**
Repos with a shared branch (e.g., 'main') and a local-only branch (e.g., 'local-only' with secrets that should never be pushed).

### make-clone.py

Clone a git repository with automated initialization.

**Features:**
- Wraps 'git clone' with transparent option pass-through
- Initializes submodules in the cloned repository
- Sets up direnv (.envrc) if available
- Prints absolute path to cloned directory

**Usage:**
```bash
# Clone into directory named after repo
make-clone.py git@github.com:user/repo.git

# Clone into specific directory
make-clone.py git@github.com:user/repo.git my-dir

# Clone with git options (URL must come first)
make-clone.py git@github.com:user/repo.git --branch develop

# Clone with custom directory and options (directory must be second)
make-clone.py git@github.com:user/repo.git my-dir --depth 1 --branch main
```

**Important:** Repository URL must come first. If providing a target directory, it must come second, before any git options.

**Shell wrapper:**
```bash
# Automatically cd into the cloned directory
make-clone git@github.com:user/repo.git
```

## Installation

1. **Install uv** (if not already installed):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **Add to PATH** (if using the dotfiles structure):
   ```bash
   # Add to your shell configuration (.bashrc, .zshrc, etc.)
   export PATH="${HOME}/.config/git/bin:${PATH}"
   ```

3. **Shell wrappers** (optional but recommended):
   Add to your shell configuration (see `shells/dot-config/shells/topics/git.sh` for examples):
   ```bash
   make-worktree() {
       if [[ "$@" == --help ]]; then
           make-worktree.py --help
       else
           local NEW_DIR
           NEW_DIR=$(make-worktree.py "$@") && cd "$NEW_DIR"
       fi
   }

   make-clone() {
       if [[ "$@" == --help ]]; then
           make-clone.py --help
       else
           local NEW_DIR
           NEW_DIR=$(make-clone.py "$@") && cd "$NEW_DIR"
       fi
   }

   alias sync-main=sync-main.py
   ```

## Shared Functionality

All utilities share common functionality through `git_shared.py`:

- **Repository resolution**: Finds git repositories from relative or absolute paths
- **Branch discovery**: Intelligently finds local and remote branches
- **Submodule initialization**: Automatically updates submodules recursively
- **Direnv setup**: Creates .envrc symlink and runs `direnv allow` if available
- **Path resolution**: Handles tilde expansion and absolute path conversion

## Testing

The project includes comprehensive test coverage (96.02% overall):

```bash
# Run tests
pytest tests/

# Run tests with coverage
./tests/run-tests-coverage.bash

# Run specific test file
pytest tests/test_make_clone.py -v
```

**Coverage by file:**
- `make-clone.py`: 100.00%
- `git_shared.py`: 97.06%
- `make-worktree.py`: 95.24%
- `sync-main.py`: 93.83%

**Test suite:**
- 58 tests total
- Unit tests for helper functions
- Integration tests for full workflows
- Direct function tests for coverage

## Dependencies

Python dependencies are managed per-script using uv's inline metadata:

- `typer`: CLI framework with type hints and automatic help generation
- `typing_extensions`: Backports of typing features

Development dependencies:
- `pytest`: Test framework
- `pytest-cov`: Coverage plugin

## Project Structure

```
git/dot-config/git/bin/
├── make-worktree.py      # Worktree creation utility
├── make-clone.py         # Clone with initialization
├── sync-main.py          # Branch synchronization
├── git_shared.py         # Shared functionality
├── tests/
│   ├── conftest.py       # Shared test fixtures
│   ├── test_make_worktree.py
│   ├── test_make_clone.py
│   ├── test_sync_main.py
│   └── run-tests-coverage.bash
├── pyproject.toml        # Coverage configuration
├── .gitignore           # Test and build artifacts
└── README.md            # This file
```

## Development

**Run tests with coverage:**
```bash
./tests/run-tests-coverage.bash
```

**View coverage report:**
```bash
open htmlcov/index.html
```

**Clean up development artifacts:**
```bash
# Preview what will be removed (dry run)
git clean -fdxn .

# Remove all build, test, and coverage artifacts
git clean -fdx .
```

This removes:
- `.venv/` - Virtual environment
- `.coverage_data/` - Coverage data files
- `htmlcov/` - HTML coverage reports
- `.pytest_cache/` - Pytest cache
- `__pycache__/` - Python bytecode cache
- `uv.lock` - UV lock file

**Note:** The `.` at the end limits the operation to the current directory only, preventing cleanup of other parts of your dotfiles repo.

**Add new utility:**
1. Create script with uv inline metadata
2. Add to git_shared.py if sharing functionality
3. Write comprehensive tests in tests/
4. Add shell wrapper in shells/dot-config/shells/topics/git.sh
5. Update this README

## Requirements

- Python 3.13+
- Git 2.0+
- uv (for running scripts)
- direnv (optional, for .envrc support)

## License

Part of Wolf's dotfiles configuration.

## Contributing

This is a personal dotfiles repository, but suggestions and improvements are welcome via issues or pull requests.
