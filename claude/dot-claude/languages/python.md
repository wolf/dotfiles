# Python

## Version

Use the most recent stable Python version unless a project specifies otherwise.

## Tools and Environment

- **Package management**: `uv`
- **Virtual environments**: Managed by `uv`, activated automatically via `direnv`
- **Pre-commit**: Always use `pre-commit` for checks including linting, type-checking, basics, and usually requiring all `pytest` tests to pass

## Code Quality

- **Linting**: `ruff`
- **Type checking**: `ty`
- **Testing**: `pytest` - tests are vital; always write them; tests should be independent and not rely on execution order
- **Coverage**: Maintain >80% coverage; always have the ability to calculate it

## Type Annotations

- Annotate all function signatures (parameters and return type)
- Functions without a return value use `-> None:`
- Use `typing_extensions` where applicable

### Type Philosophy

- **Parameters**: Accept the broadest reasonable type that accomplishes what the function needs
- **Return types**: Return the narrowest type, adjusted by:
  - What is most useful to the caller
  - What is the Pythonic convention
  - What promise does the type make (e.g., `list` implies order is meaningful; consider whether `Sequence`, `Iterable`, or `set` better expresses intent)

## Style

Write Pythonic code. Prefer clarity and idiom over cleverness. Use the best names possible for variables, functions, classes, and modules. Prefer double quotes (`"`) over single quotes (`'`).

## Docstrings

Use docstrings at every level: module, class, method, and function. Use Markdown formatting.

**Single-line docstrings**: `"""Create the thing."""`
- Imperative mood, ends with a period
- Same line as the surrounding quotes, no separation

**Multi-line docstrings**:
```python
"""
Create the thing with the given parameters.

Additional details here. Like a git commit message: succinct imperative
summary, blank line, then paragraphs as needed.

"""
```
- Opening and closing `"""` on their own lines
- Summary immediately after opening quotes, left-aligned
- Blank line after summary, then body
- Blank line before closing `"""` (NumPy style convention)

**Content guidelines**:
- Include testable code (doctests) where useful
- Don't mention types (we use annotations)
- No arguments section (good names + annotations suffice); may discuss relationships between arguments when important
- Don't describe the return value unless details are critical beyond what the summary conveys
- Do mention exceptions raised
- Do mention invariants maintained when important
- Be succinct

**When to omit**: Obvious functions (one-liners, well-known interfaces like `Container`) may skip docstrings. Add a comment to suppress the linter warning.

## Comments

Like docstrings: succinct, Markdown, only where needed. Comments explain the "why"; code is the "how". Use comments when the technique, code, or result is surprising or non-Pythonic. Obvious code is better than non-obvious code with good comments.
