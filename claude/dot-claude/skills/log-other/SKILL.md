---
name: log-other
description: Log an external activity to daily work log
argument-hint: "[description]"
allowed-tools: Read, Write, Edit, AskUserQuestion, mcp__things__*
---

# Log External Activity

Log work done outside this environment (meetings, documentation, tickets, merges, etc.) to the daily work log. Argument: `$ARGUMENTS` (activity description, optional).

## Conventions

Read `~/Vaults/Notes/0-log/worklog/CLAUDE.md` for the canonical worklog
format — frontmatter schema, entry format, duration short forms, and client
attribution rules.

## Location

Write to: `~/Vaults/Notes/0-log/worklog/YYYY/MM/YYYY-MM-DD.md`

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
- Duration uses short form only: `3h`, `30m`, `1.5h`, `~2h`
- Body text is optional — only include if the user provides details worth recording

## Frontmatter

When creating or appending to a daily file, **always read the existing file
first**, then update the YAML frontmatter to reflect all entries (including the
new one). See the worklog CLAUDE.md for the full frontmatter schema.

## Things Integration

After adding the entry, check today's Things tasks for matches. If a matching task exists, ask if it should be marked complete or updated.

## Carry Forward

After the Things step, ask: "Anything to carry forward for tomorrow?"

* If the user says no (or equivalent), skip.
* If yes, take their input and append a bullet to the `## Pick-up` section
  at the bottom of the worklog file.
* If the section doesn't exist yet, create it (as the last `##` section in
  the body).
* Lead with **ticket ID** (bold) if the entry had a ticket.
* Keep the bullet concise — next action, blocker, or context to resume.
* Do not add to frontmatter or change hours/totals.
