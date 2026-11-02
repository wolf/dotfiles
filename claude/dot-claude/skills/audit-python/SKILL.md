---
name: audit-python
description: Systematic code audit of a Python codebase against DMP standards
argument-hint: "[scope: changes, file/dir path, or 'all']"
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion, mcp__mcp-atlassian__jira_get_issue, mcp__mcp-atlassian__jira_search
model: opus
---

# Audit Python — Systematic Code Audit

Audit Python code against the DMP code audit checklist. Argument:
`$ARGUMENTS` (optional scope hint — see below).

## When to Trigger

* User says "audit this", "review this code", "let's audit"
* After a major refactor or before a release, when the user wants a thorough review

## Step 1: Load the Checklist

Read the canonical checklist — do not hardcode rules:

```
~/develop/dmp/dmp-coding-standards/code-audit-checklist.md
```

This file defines every section and check item. If it has changed since you
last saw it, the audit reflects the current version automatically.

The checklist references several standards documents, all siblings of it in
`~/develop/dmp/dmp-coding-standards/` — WHAT-MATTERS-MOST.md,
STANDARDS-FOR-SHARED-PROJECTS.md, DMP-PYTHON-STANDARDS.md, and others. Read
these once if they are not already in the current conversation context. If
you've already read them in this session, don't re-read.

## Step 2: Gather Inputs

### Automatic

* Read the project's vault inbox (`~/Vaults/Notes/2-projects/dmp/<project-name>/inbox.md`) and/or `inbox.local-only.md` in the project root if either exists. Note any items that relate to code quality, design issues, or audit-relevant observations.

### Prompted

Ask the user:

1. **Jira context.** "Any Jira tickets I should pull for context? (ticket
   keys, a JQL query, or 'skip')" — If provided, fetch the tickets and
   extract relevant context (known bugs, design decisions, complaints).

2. **Audio notes / braindumps.** "Any notes, observations, or things you've
   been thinking about for this audit? (paste, file path, or 'skip')"

3. **Consumer code.** "Any client/consumer code I should look at to
   understand how this library is used? (paths or 'skip')"

Do NOT look in OmniFocus.

## Step 3: Determine Scope

If `$ARGUMENTS` specifies scope, use it. Otherwise ask:

> What should I audit?
> * **changes** — only files changed in the current branch (vs main)
> * **file or directory path** — a specific area
> * **all** — the entire project

For "changes" scope, derive the file list from:
```bash
git diff --name-only main...HEAD
```
Plus any unstaged/staged changes:
```bash
git diff --name-only
git diff --name-only --cached
```

For directory scope, discover all Python files in that tree.

For "all" scope, discover all Python files in the project (respect
`.gitignore`).

## Step 4: Audit

Work through each section of the checklist against the scoped code.

### How to audit

* **Read the code.** Don't guess — read every file in scope.
* **Apply each check item** from the checklist to the code you've read.
  Not every item will apply to every codebase. Skip items that are clearly
  irrelevant (e.g., "Export/import symmetry" for a CLI tool with no data
  model).
* **Record findings**, not checks. Only note items where you found something
  — a problem, a question, or a notable strength. Don't list "N/A" for
  every inapplicable check.
* **Be specific.** Every finding must reference a file and line number (or
  function/class name). Vague findings are useless.
* **Distinguish severity:**
  * **Issue** — something that should change
  * **Question** — something that might be wrong but needs human judgment
  * **Note** — an observation worth recording (including positive ones)

### Upgrade report (every audit, whatever the scope)

The Interpreter and Dependencies section of the checklist requires every audit to report available upgrades, even for "changes" scope and even when nothing is urgent. Gather the facts, don't guess from memory:

* **Interpreter.** Find the project's Python (`.python-version`, `requires-python`, the lock or environment) and compare it with the newest Python available (`uv python list --only-downloads`, and the security-release list in `DMP-PYTHON-STANDARDS.md` § Version Policy). Report a newer security release of its minor and a newer minor.
* **Ready for the newest Python.** Check that the code compiles and the tests pass under the newest Python available (for example `uv run --python <newest> pytest`, or look for CI that does this). If you can't run it, say so rather than assuming.
* **Dependencies.** Preview what an upgrade would pick up, honoring the 4-day floor and without changing the lockfile: `uv lock --upgrade --dry-run --exclude-newer "4 days"` (for pixi, `pixi update --dry-run`). A project that resolves from the internal devpi skips `--exclude-newer`. List direct dependencies that are behind, and any transitive one with a security fix. Note anything blocked, and by what.
* **Suggest, don't do.** The audit never edits `pyproject.toml`, the lockfile, or the interpreter pin. Upgrades are suggestions for the user to approve.

### Pace yourself

For large codebases, work module by module. After each module, briefly
report what you found before moving on. This keeps the user informed and
lets them steer ("skip that area", "go deeper here").

## Step 5: Present Summary

After completing the audit, present a clear textual summary organized by
checklist section. For each section with findings:

```
## Section Name

* **Issue** `path/file.py:42` — Description of what's wrong and why it
  matters
* **Question** `path/other.py:SomeClass` — Is this intentional? It looks
  like X but the usual pattern is Y
* **Note** `path/good.py:helper_func` — Nice use of protocol conformance
  here
```

Always include an **Upgrades Available** section, even when it only says everything is current:

```
## Upgrades Available

* **Python** 3.14.8 → 3.14.10 (security release); 3.15.2 is also available. Code passes tests on 3.15.2 / not yet tried.
* **Dependency** `loguru` 0.7.2 → 0.7.3 (no blocker)
* **Blocked** `somelib` stays at 2.x: consumer X requires it
```

Mark upgrades that are overdue (a security release, a full minor or major behind with no stated blocker) as **Issue**, the rest as **Note**. Flag a lockfile that is months old.

End with a brief overall assessment: what's the general health of this code?
What are the most important things to address?

## Step 6: Offer to Save

After presenting the summary, ask:

> "Save findings to AUDIT.local-only.md? (yes/no)"

If yes, write the findings to `AUDIT.local-only.md` in the project root.
Use the same format as the summary, but also include:

* A header with the date, scope, and any Jira context
* The full findings (not abbreviated)

Then offer the next step:

> "Want to prioritize these findings? (This adds A/B/C ratings and scope
> estimates)"

## Step 7: Prioritize (only after saving)

This step only runs when findings have been saved to `AUDIT.local-only.md`.
Prioritizing requires seeing all findings together.

For each finding, add:

* **Priority:** A (must do), B (should do), C (could do)
* **Scope:** trivial, small, medium, large

Work through this interactively — present findings in groups and let the
user assign or confirm ratings. Update `AUDIT.local-only.md` with the
ratings.

After prioritization, the format becomes:

```
* **[A/small]** **Issue** `path/file.py:42` — Description
* **[B/medium]** **Question** `path/other.py:SomeClass` — Description
```

Order findings: A items first (by scope ascending), then B, then C.

Note any dependency chains ("X should be done before Y").

The prioritized AUDIT file is the input for filing tickets, which is a
separate step outside this skill.
