---
name: log-other
description: Log an external activity to daily work log
argument-hint: "[description]"
allowed-tools: Read, Write, Edit, AskUserQuestion, mcp__things__*
---

# Log External Activity

Log work done outside this environment (meetings, documentation, tickets, merges, etc.) to the daily work log. Argument: `$ARGUMENTS` (activity description, optional).

## Location

Write to: `~/Vaults/Notes/0-inbox/worklog/YYYY/MM/YYYY-MM-DD.md`

Create year and month directories as needed.

## Gather Information

**Description**: Use `$ARGUMENTS` if provided as a starting point. Always confirm or refine with the user since you have no session context for external activities.

**Ask the user for:**
- **Duration**: How long did this take?
- **Ticket**: Is this related to a ticket (Jira, GitHub issue)? If so, note the number and a brief summary.
- **Attribution**: Who is this work for? Check for project-specific CLAUDE.md attribution rules first. If none exist and it's not obvious, ask.
- **Details**: Anything else worth noting? (Optional — keep it brief if so.)

## Format

Append to the file (create if needed):

```markdown
## Activity Description Here

Ticket: PROJ-123 - Brief ticket summary
Duration: 30m (ClientName)

Optional brief details.
```

Notes:
- Ticket line is optional (omit if no ticket)
- Attribution in parentheses after duration is optional (omit if personal work)
- Body text is optional — only include if the user provides details worth recording

## Things Integration

After adding the entry, check today's Things tasks for matches. If a matching task exists, ask if it should be marked complete or updated.
