# Python

## Version

Use the most recent stable Python version unless a project specifies otherwise.

## Tools and Environment

- **Package management**: `uv`
- **Virtual environments**: Managed by `uv`, activated automatically via `direnv`
- **Hooks**: Always use `prek` (not `pre-commit`) for checks including linting, type-checking, basics, and usually requiring all `pytest` tests to pass. prek reads the same `.pre-commit-config.yaml` format
- **Before staging**: Run `ruff format` on changed files so prek hooks are a safety net, not a reformatter

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

`__all__` should be a tuple (not a list), sorted alphabetically, with one name per line in vertical format.

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

## Density

Write compact, experienced Python. The reader is fluent; don't spell out what the language already says.

* **Comprehensions over loops.** If a loop exists only to build a collection, it should be a comprehension or generator expression. A `for` loop that appends to a list is almost always wrong.
* **Walrus operator (`:=`).** Use it to avoid computing a value, checking it, then using it on separate lines. `if (x := expensive()) is not None:` beats three lines.
* **Compound conditionals.** `if a and b:` instead of nesting `if a:` / `if b:`. Same for `if not x: continue` at the top of a loop vs wrapping the body in `if x:`.
* **`next()` for single-item search.** `next((x for x in items if pred(x)), None)` beats a loop-with-break.
* **Yield, don't collect.** If a function builds a list only to return it, it should `yield` instead (or `yield from` a comprehension). Let callers decide the container.
* **Data-driven over copy-paste.** When N blocks differ only in a few values, extract those values into a table (tuple of tuples, dict, etc.) and loop over it. Three similar blocks → one loop over three rows.
* **Early return / continue.** Flatten nesting by returning or continuing early instead of wrapping the happy path in an `else`.
* **One expressive line > three obvious lines.** If chaining, unpacking, or a conditional expression makes the intent clearer in one line, prefer it.

These are not about cleverness — they're about matching the density an experienced reader expects. Verbose code wastes vertical space and obscures structure.

## Comments

Like docstrings: succinct, Markdown, only where needed. Comments explain the "why"; code is the "how". Use comments when the technique, code, or result is surprising or non-Pythonic. Obvious code is better than non-obvious code with good comments.
