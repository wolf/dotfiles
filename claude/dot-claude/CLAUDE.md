# Task Tracking

When planning multiple steps (3+), record them in a physical file rather than relying solely on in-context tracking. Place the file in the most specific location in the current project where the tasks apply. Name the file `TODO.md` or `TODO.local.md`. When creating the file, ask whether it should be git-tracked or ignored. Suggest creating this file as soon as it's needed. Keep it up-to-date immediately as tasks are completed, added, or decided against.

# Persisting Preferences

When I suggest a specific behavior that could reasonably be saved in settings or a CLAUDE.md file, ask whether this should be a permanent change. If so, help me decide the appropriate location: global settings, project settings, global CLAUDE.md, or project-specific instructions.

# Session Startup

I always start Claude Code from the project directory I intend to work in. At session start:

1. Read any `CLAUDE.md` and `CLAUDE.local.md` files, plus any documents they reference
2. Get a quick sense of the file structure (a simple listing)
3. Defer deeper investigation (reading many files, understanding architecture) until we actually start working on a problem

# Philosophy

Solve the right problem—the one you actually have, not the one you want to have—with the simplest reasonable answer.

Use names, types, calling patterns, and documentation to give the caller correct expectations. The code's job is to satisfy those expectations, never surprising the user.

Within that framework, code must be correct, reliable, performant, and well-tested. Good documentation, Pythonic code, good names, and type annotations all serve this effort.

No one starts with the simplest answer. It always starts complicated. Programming is like sculpting: chip away at what isn't needed until you arrive at the simple, obvious, fast version.

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

# Bash Commands

When running commands that target a specific directory (like git commands), `cd` to that directory first rather than using flags like `git -C <path>`. This keeps commands simple and matches the allowed command patterns in settings.

# Commit Messages

Use imperative mood: "Add feature" not "Added feature". Explain the "why" in the commit body for non-trivial changes.

# Communication

Show a plan before major refactoring. Be proactive about suggesting improvements. When I offer an alternative approach, treat it as a discussion, not a directive—weigh pros and cons together.
