#!/usr/bin/env bash
# Run tests with coverage and optionally open the HTML report

set -e

cd "$(dirname "$0")/.."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running tests with coverage...${NC}"

# Clean up old coverage data
rm -f .coverage .coverage.*
rm -rf htmlcov/

# Run pytest with coverage
uv run --no-project pytest tests/ \
    --cov=. \
    --cov-report=term-missing \
    --cov-report=html \
    -v

# Combine parallel coverage data (from subprocess calls)
echo -e "\n${BLUE}Combining coverage data...${NC}"
uv run --no-project coverage combine 2>/dev/null || true

# Generate final reports
echo -e "\n${BLUE}Generating coverage reports...${NC}"
uv run --no-project coverage report
uv run --no-project coverage html

echo -e "\n${GREEN}✓ Tests complete!${NC}"
echo -e "${BLUE}Coverage report: htmlcov/index.html${NC}"

# Ask if user wants to open the report
if [ -t 0 ]; then
    read -p "Open coverage report in browser? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v open &> /dev/null; then
            open htmlcov/index.html
        elif command -v xdg-open &> /dev/null; then
            xdg-open htmlcov/index.html
        else
            echo "Could not detect browser opener. Please open htmlcov/index.html manually."
        fi
    fi
fi
