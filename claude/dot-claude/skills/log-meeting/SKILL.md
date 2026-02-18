---
name: log-meeting
description: Log a meeting to daily work log
argument-hint: "[meeting name]"
allowed-tools: Read, Write, Edit, AskUserQuestion, mcp__things__*, mcp__apple-events__calendar_events
---

# Log Meeting

Log a meeting to the daily work log. Argument: `$ARGUMENTS` (meeting name, optional).

## Conventions

Read `~/Vaults/Notes/0-inbox/worklog/CLAUDE.md` for the canonical worklog
format — frontmatter schema, entry format, duration short forms, client
attribution rules, entry types, and calendar integration rules.

## Location

Write to: `~/Vaults/Notes/0-inbox/worklog/YYYY/MM/YYYY-MM-DD.md`

Create year and month directories as needed.

## Routing

- **`$ARGUMENTS` is non-empty** → Ad-hoc flow (Path A)
- **`$ARGUMENTS` is empty** → Calendar flow (Path B)

---

## Path A — Ad-hoc Flow

Use this when `$ARGUMENTS` contains a meeting name (e.g., `/log-meeting standup with Dave`).

### Gather Information

**Title**: Use `$ARGUMENTS`.

**Ask the user for:**
- **Duration**: How long was the meeting?
- **Attribution**: Who is this for? Check for project-specific CLAUDE.md attribution rules first. If none exist and it's not obvious, ask.
- **Ticket**: Is this related to a ticket? (Optional)
- **Notes**: Anything worth noting? Decisions made, topics discussed. Keep brief. (Optional)
- **Action items**: Any action items from this meeting? (Optional — freeform list)

Then proceed to **Format**, **Frontmatter**, **Things Integration**, and **Loop** below.

---

## Path B — Calendar Flow

Use this when `$ARGUMENTS` is empty.

### 1. Fetch Today's Events

Call `mcp__apple-events__calendar_events` with:
- `action: "read"`
- `startDate`: today's date (`YYYY-MM-DD`)
- `endDate`: today's date (`YYYY-MM-DD`)

If the calendar fetch fails, warn the user and offer to fall back to ad-hoc
flow (Path A without a pre-filled title — ask for the meeting name).

### 2. Filter to Real Meetings

Apply the Calendar Integration rules from `worklog/CLAUDE.md`. Keep an event
only if **all** of the following are true:

1. **Has attendees other than just me**: at least one attendee where
   `isCurrentUser` is `false`.
2. **My status is accepted**: find the attendee where `isCurrentUser` is
   `true` and check that `status === "accepted"`.
3. **Not on a holiday or birthday calendar**: skip events whose calendar name
   contains "holiday", "birthday", or "Birthdays" (case-insensitive).
4. **Not an all-day event**: skip events where `isAllDay` is true.
5. **Not multi-day or spanning midnight**: skip events whose start and end
   dates fall on different days.

### 3. Check Already-Logged Entries

Read today's worklog file. Compare calendar event titles against logged entry
titles using fuzzy matching (calendar title may differ slightly from logged
title). Mark calendar events that already have a matching log entry.

### 4. Present Unlogged Meetings

If no unlogged meetings remain, say: "No unlogged meetings on your calendar
today. Want to log an ad-hoc meeting instead?" If yes, switch to Path A
(ask for meeting name). If no, end.

Otherwise, show a numbered list of unlogged meetings. For each, show:
- Title
- Time range (e.g., 10:00–11:00)
- Duration computed from start/end times
- Attendees (first names or count if many)

### 5. User Picks Meetings

Let the user pick which meetings to log: specific numbers, "all", or "none".

### 6. Log Each Selected Meeting

For each selected meeting, gather information and log it:

- **Title**: Pre-fill from calendar event title. Ask if the user wants to
  adjust it.
- **Duration**: Compute from start/end times, rounded to nearest 15 minutes.
  Confirm with user (meetings sometimes run short).
- **Client**: Infer from the calendar name the event is on. If the calendar
  name hasn't been mapped to a client before in this session, ask the user
  for the mapping (e.g., "Calendar 'Work' → which client?"). Apply CLAUDE.md
  attribution rules.
- **Ticket**: Ask (optional).
- **Notes / action items**: Ask (optional). Since these are past meetings,
  the user may have something quick to note.

Then proceed to **Format**, **Frontmatter**, and **Things Integration** below
for each meeting.

### 7. After Calendar Meetings

After processing all selected calendar meetings, ask: "Log another meeting?"
This covers ad-hoc meetings not on the calendar. If yes, switch to Path A
(ask for meeting name).

---

## Format

Append to the file (create if needed):

```markdown
## Meeting Title Here

Ticket: PROJ-123 - Brief ticket summary
Duration: 1h (ClientName)

Brief notes about the meeting.

Action items:
- First action item
- Second action item
```

Notes:
- Ticket line is optional (omit if no ticket)
- Attribution in parentheses after duration is optional (omit if personal)
- Duration uses short form only: `3h`, `30m`, `1.5h`, `~2h`
- Body text is optional — only include if the user provides notes
- Action items section is optional — only include if the user provides them

## Frontmatter

When creating or appending to a daily file, **always read the existing file
first**, then update the YAML frontmatter to reflect all entries (including the
new one). See the worklog CLAUDE.md for the full frontmatter schema.

The entry **must** include `type: meeting` in the frontmatter entries list.

## Things Integration

After adding the entry:
- For each action item, offer to create a Things task
- Check today's Things tasks for matches to the meeting itself. If a matching task exists, ask if it should be marked complete or updated.

## Loop

After finishing the entry (or batch of calendar entries), ask: "Log another
meeting?" If yes, start over from the appropriate flow.
