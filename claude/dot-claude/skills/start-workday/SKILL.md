---
name: start-workday
description: Clock in — start tracking workday hours
argument-hint: "[time] [client] [date]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Start Workday

Clock in for a client. Argument: `$ARGUMENTS` (optional time and client).

## Conventions

Read `~/Vaults/Notes/0-log/worklog/CLAUDE.md` for the canonical worklog
format — frontmatter schema, workday tracking rules.

## Parse Arguments

Extract optional **time**, optional **client**, and optional **date** from
`$ARGUMENTS`:

- **Time**: `8am`, `8:30am`, `17:00`, etc. Default: current time via
  `date +%H:%M`.
- **Date**: a recognizable date shape — `yesterday`, `2026-02-25`, a weekday
  name. Default: **today**. Resolve this token before treating anything left
  over as the client, so a date-shaped token is never mistaken for one.
- **Client**: any remaining non-time, non-date token. Default: `DMP`.
- Arguments can appear in any order.

Examples:
- `/start-workday` → DMP, now, today
- `/start-workday 8am` → DMP, 08:00, today
- `/start-workday Personal` → Personal, now, today
- `/start-workday Personal 8am` → Personal, 08:00, today
- `/start-workday 8:30am DMP` → DMP, 08:30, today
- `/start-workday 8am DMP yesterday` → DMP, 08:00, yesterday

Normalize time to 24-hour `HH:MM` format. Resolve date to `YYYY-MM-DD`.

## Procedure

1. **Resolve time**: If no time in arguments, run `date +%H:%M` for current time.
2. **Resolve date**: If no date in arguments, use today's date. Resolve
   relative dates (`yesterday`, weekday names) to `YYYY-MM-DD`.
3. **Read daily file**: `~/Vaults/Notes/0-log/worklog/YYYY/MM/YYYY-MM-DD.md`
   (resolved date). Create year/month directories and file with minimal
   frontmatter if it doesn't exist. **If you just created the file and the
   resolved date is today**, invoke `/daily-checks` after
   writing the initial frontmatter and before continuing — this fires the
   once-per-day silent housekeeping checks. Continue with the rest of the
   procedure regardless of their outcome. A past-dated file never triggers
   this.
4. **Guard**: If there's already an open segment (a `workday` entry with no
   `end`), warn the user and ask whether to close it first (set its `end` to
   now) or abort.
5. **Append segment**: Add `{client, start}` to the `workday` list in
   frontmatter. Create the `workday` list if it doesn't exist.
6. **Write file**: Update frontmatter, preserve body.
7. **Confirm**: "Clocked in for **{client}** at {time}" (add "on {date}" when
   the date isn't today).
