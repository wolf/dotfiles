#!/usr/bin/env bash
# Run every gate for jpr-recordings.py: format, lint, type-check, and tests.
# No project venv is created — ruff/ty run against the ambient tools, and ty
# is pointed at the script's own uv-managed PEP 723 environment so it can
# resolve typer and loguru exactly as the shebang does.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "ruff format --check"
ruff format --check .

echo "ruff check"
ruff check .

echo "uv sync --script (ensures the script's own environment exists)"
uv sync --script jpr-recordings.py --quiet

echo "ty check"
ty check --python "$(uv python find --script jpr-recordings.py)" jpr-recordings.py

echo "pytest"
uv run --no-project --with pytest --with pytest-cov --with typer --with loguru \
    pytest

echo "All gates passed."
