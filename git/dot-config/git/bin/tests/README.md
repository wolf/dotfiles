# Tests

Comprehensive test suite for the git utility scripts.

## Running Tests

### Quick Start

Run all tests with coverage and view the HTML report:

```bash
./tests/run-tests-coverage.bash
```

The script will:
- Clean up old coverage data
- Run all tests with pytest
- Generate terminal and HTML coverage reports
- Offer to open the HTML report in your browser

### Running Specific Tests

Run tests for a specific file:

```bash
uv run --no-project pytest tests/test_sync_main.py -v
```

Run a specific test:

```bash
uv run --no-project pytest tests/test_sync_main.py::test_sync_main_with_stash -v
```

### Running Tests Without Coverage

If you just want to run tests quickly without coverage tracking:

```bash
uv run --no-project pytest tests/ -v
```

## Test Structure

### `conftest.py`

Shared pytest fixtures and helpers used across all test files:

- **`run_script_with_coverage(script_path, args, **kwargs)`**: Helper to run scripts through coverage for subprocess execution tracking
- **`git_repo`**: Fixture that creates a temporary git repository with initial commit
- **`git_repo_with_remote`**: Fixture that creates a git repo with a remote (bare repo)

### `test_make_worktree.py`

Tests for `make-worktree.py`:
- **Unit tests**: Helper functions (`resolve_path`, `is_absolute_repo_path`)
- **Integration tests**: CLI behavior, worktree creation, remote branches, `.envrc` handling

### `test_sync_main.py`

Tests for `sync-main.py`:
- **Unit tests**: Helper functions (`run_git`, `current_branch`, `has_uncommitted_changes`)
- **Integration tests**: Syncing workflows, stashing, different branches, edge cases

## Adding New Tests

### For a New Script

1. Create a new test file: `tests/test_your_script.py`
2. Import the shared helpers from `conftest.py`:
   ```python
   from conftest import run_script_with_coverage, git_repo
   ```
3. Import your script using `importlib`:
   ```python
   import importlib.util
   from pathlib import Path

   SCRIPT_PATH = Path(__file__).parent.parent / "your-script.py"
   spec = importlib.util.spec_from_file_location("your_script", SCRIPT_PATH)
   your_script = importlib.util.module_from_spec(spec)
   spec.loader.exec_module(your_script)
   ```
4. Write unit tests for helper functions
5. Write integration tests using `run_script_with_coverage()`

### Testing Best Practices

- **Use long option names** in test code and scripts (e.g., `--include-untracked` not `-u`)
- **Test both success and failure cases**
- **Use fixtures** from `conftest.py` to avoid duplication
- **Descriptive test names**: `test_sync_main_with_multiple_commits` not `test_case_3`
- **Good docstrings**: Explain what the test validates
- **Integration tests**: Use `run_script_with_coverage()` to test the actual CLI
- **Simulate remote changes**: Use separate clones to avoid git detecting local commits

## Coverage Reports

### Terminal Report

Shows coverage summary with missing lines:

```
Name               Stmts   Miss   Cover   Missing
-------------------------------------------------
make-worktree.py      91      3  96.70%   134, 227, 252
sync-main.py          93      2  97.85%   85, 102
```

### HTML Report

Interactive report with line-by-line coverage highlighting:

```bash
open htmlcov/index.html
```

The HTML report shows:
- Overall coverage statistics
- Per-file coverage with color-coded lines
- Which lines were executed and which weren't
- Branches taken/not taken

## Configuration

Test configuration is in `../pyproject.toml`:

```toml
[tool.coverage.run]
source = ["."]
parallel = true          # Support parallel coverage collection
omit = ["tests/*"]       # Don't measure coverage of test files

[tool.coverage.report]
exclude_lines = [        # Patterns to exclude from coverage
    "pragma: no cover",
    "if __name__ == .__main__.:",
]
precision = 2            # Show coverage to 2 decimal places

[tool.coverage.html]
directory = "htmlcov"    # HTML report output directory
```

## Troubleshooting

### Tests are slow

The integration tests create real git repositories and simulate remote operations, which takes time. This is intentional to ensure the scripts work correctly in real scenarios.

To run only fast unit tests:
```bash
uv run --no-project pytest tests/ -v -k "not cli"
```

### Coverage data not combining

If you see "No data to combine", it means coverage isn't tracking subprocess execution properly. The tests will still pass, but coverage numbers may be lower than actual. This is a known limitation when testing scripts via subprocess.

### Test failures in git operations

Make sure you have git configured with user name and email:
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

The fixtures set these in test repos, but some git operations might use your global config.
