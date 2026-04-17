---
name: audit-python
description: Systematic code audit of a Python codebase against DMP standards
argument-hint: "[scope: changes, file/dir path, or 'all']"
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion, mcp__mcp-atlassian__jira_get_issue, mcp__mcp-atlassian__jira_search
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
~/develop/dmp/standards/code-audit-checklist.md
```

This file defines every section and check item. If it has changed since you
last saw it, the audit reflects the current version automatically.

The checklist references several standards documents (WHAT-MATTERS-MOST.md,
STANDARDS-FOR-SHARED-PROJECTS.md, DMP-PYTHON-STANDARDS.md, etc.). Read these
once if they are not already in the current conversation context. If you've
already read them in this session, don't re-read.

## Step 2: Gather Inputs

### Automatic

* Read `inbox.local-only.md` in the project root if it exists. Note any
  items that relate to code quality, design issues, or audit-relevant
  observations.

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
