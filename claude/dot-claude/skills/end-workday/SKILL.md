---
name: end-workday
description: Clock out — stop tracking workday hours
argument-hint: "[time] [date]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, mcp__mcp-atlassian__jira_search, mcp__things__*, mcp__omnifocus__*
---

# End Workday

Clock out of the current workday segment. Argument: `$ARGUMENTS` (optional time).

## Conventions

Read `~/Vaults/Notes/0-log/worklog/CLAUDE.md` for the canonical worklog
format — frontmatter schema, workday tracking rules.

## Parse Arguments

Extract optional **time**, optional **date**, and **flags** from
`$ARGUMENTS`:

- **Time**: `5pm`, `17:00`, `5:30pm`, etc. Default: current time via
  `date +%H:%M`.
- **Date**: `yesterday`, `2026-02-25`, a weekday name. Default: **today**.
- **`--no-pickup`** or **`--quick`**: Skip the pick-up review phase entirely.

Normalize time to 24-hour `HH:MM` format. Resolve date to `YYYY-MM-DD`.

## Procedure

1. **Resolve time**: If no time in arguments, run `date +%H:%M` for current time.
2. **Resolve date**: If no date in arguments, use today's date. Resolve
   relative dates (`yesterday`, weekday names) to `YYYY-MM-DD`.
3. **Read daily file**: `~/Vaults/Notes/0-log/worklog/YYYY/MM/YYYY-MM-DD.md`
   (resolved date). Error if the file doesn't exist — nothing to clock out of.
4. **Find open segment**: Look for a `workday` entry with no `end`.
   - If none: warn "No open workday segment to close." and stop.
   - If multiple (shouldn't happen): ask the user which to close.
5. **Close segment**: Set `end` on the open segment.
6. **Compute duration**: `end - start` in decimal hours (e.g., 08:00→17:00 = 9h).
7. **Write file**: Update frontmatter, preserve body.
8. **Pick-up review**: See below.
9. **Accomplishment check**: After confirming clock-out, ask: "Anything from today worth logging as a notable accomplishment? (`/accomplishment`)"
10. **Confirm**: "Clocked out of **{client}** at {time} ({duration})" (add "on
    {date}" when the date isn't today).

## Pick-up Review

### Gate check

Skip this entire phase if any of these are true:
* `--no-pickup` or `--quick` flag was passed
* The closed segment's client is not DMP

### Jira supplement

1. Search Jira:
   `assignee = currentUser() AND status = "In Progress" AND sprint in openSprints()`
2. Compare returned tickets against existing `## Pick-up` bullets
3. For any in-progress ticket NOT already mentioned in pick-up, draft a
   bullet: `* **SE-XXXX**: [summary] — in progress, not worked on today`
4. If there are new bullets, append them to the `## Pick-up` section
   (create the section if it doesn't exist)

### Review

1. Read the full `## Pick-up` section (including anything added during the
   day and the Jira supplement)
2. Present it to the user: "Here's tomorrow's pick-up. Edit, approve, or
   skip?"
3. If the user edits, apply changes and rewrite the section
4. If approved, leave as-is
5. If skipped, ask whether to remove the section or leave it
