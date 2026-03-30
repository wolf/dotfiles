---
name: log
description: Log work to daily work log — session work or external activity
argument-hint: "[description]"
allowed-tools: Read, Write, Edit, AskUserQuestion, mcp__omnifocus__*
---

# Log Work

Add an entry to the daily work log. Argument: `$ARGUMENTS` (description, optional).

Handles both **session work** (done in this Claude session) and **external
activity** (done outside this environment). Infer which from context:

* If there's recent session work and no indication of external activity →
  session mode (pre-fill from session context)
* If the user describes work done elsewhere ("before this session I...",
  "I spent 2h on...") → external mode (ask for details since you have no
  session context)
* If ambiguous, ask.

## Conventions

Read `~/Vaults/Notes/0-log/worklog/CLAUDE.md` for the canonical worklog
format — frontmatter schema, entry format, duration short forms, and client
attribution rules.

## Location

Write to: `~/Vaults/Notes/0-log/worklog/YYYY/MM/YYYY-MM-DD.md`

Create year and month directories as needed.

## Gather Information

**Description**: Use `$ARGUMENTS` if provided. In session mode, pre-fill from
what was just accomplished. In external mode, confirm or refine with the user.

**Ask the user for:**
* **Duration**: How long did this take?
* **Ticket**: Related to a ticket? If so, note the number and a brief summary.
* **Attribution**: Who is this work for? Check for project-specific CLAUDE.md
  attribution rules first. If none exist and it's not obvious, ask.
* **Details**: (External mode only) Anything worth noting? Keep it brief.

## Format

Append to the file (create if needed):

```markdown
## Task Description Here

Ticket: PROJ-123 - Brief ticket summary
Duration: 2h (ClientName)

Optional brief details.
```

Notes:
* Ticket line is optional (omit if no ticket)
* Attribution in parentheses after duration is optional (omit if personal work)
* Duration uses short form only: `3h`, `30m`, `1.5h`, `~2h`
* Skip ephemeral details like commit IDs that won't matter after merge
* Body text is optional — only include if worth recording

## Frontmatter

When creating or appending to a daily file, **always read the existing file
first**, then update the YAML frontmatter to reflect all entries (including the
new one). See the worklog CLAUDE.md for the full frontmatter schema.

## Task Manager Integration

After adding the entry, check OmniFocus for matching tasks. If a match exists,
ask if it should be marked complete or updated.

## Carry Forward

After the task manager step, ask: "Anything to carry forward for tomorrow?"

* If the user says no (or equivalent), skip.
* If yes, take their input and append a bullet to the `## Pick-up` section
  at the bottom of the worklog file.
* If the section doesn't exist yet, create it (as the last `##` section in
  the body).
* Lead with **ticket ID** (bold) if the entry had a ticket.
* Keep the bullet concise — next action, blocker, or context to resume.
* Do not add to frontmatter or change hours/totals.
