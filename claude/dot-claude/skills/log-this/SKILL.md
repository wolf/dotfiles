---
name: log-this
description: Log current session work to daily work log
disable-model-invocation: true
argument-hint: "[description]"
allowed-tools: Read, Write, Edit, mcp__things__*
---

# Add Work Log Entry

Add an entry to the daily work log. Argument: `$ARGUMENTS` (task description, optional).

## Location

Write to: `~/Vaults/Notes/0-inbox/worklog/YYYY/MM/YYYY-MM-DD.md`

Create year and month directories as needed.

## Gather Information

**Description**: Use `$ARGUMENTS` if provided, otherwise ask what was accomplished.

**Ask the user for:**
- **Duration**: How long did this task take?
- **Ticket**: Is this related to a ticket (Jira, GitHub issue)? If so, note the number and a brief summary.
- **Attribution**: Who is this work for? Check for project-specific CLAUDE.md attribution rules first. If none exist and it's not obvious, ask.

## Format

Append to the file (create if needed):

```markdown
## Task Description Here

Ticket: PROJ-123 - Brief ticket summary
Duration: 2h (ClientName)
```

Notes:
- Ticket line is optional (omit if no ticket)
- Attribution in parentheses after duration is optional (omit if personal work)
- Skip ephemeral details like commit IDs that won't matter after merge

## Things Integration

After adding the entry, check today's Things tasks for matches. If a matching task exists, ask if it should be marked complete or updated.
