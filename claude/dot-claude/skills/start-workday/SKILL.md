---
name: start-workday
description: Clock in — start tracking workday hours
argument-hint: "[time] [client]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Start Workday

Clock in for a client. Argument: `$ARGUMENTS` (optional time and client).

## Conventions

Read `~/Vaults/Notes/0-log/worklog/CLAUDE.md` for the canonical worklog
format — frontmatter schema, workday tracking rules.

## Parse Arguments

Extract optional **time** and optional **client** from `$ARGUMENTS`:

- **Time**: `8am`, `8:30am`, `17:00`, etc. Default: current time via
  `date +%H:%M`.
- **Client**: any non-time token. Default: `DMP`.
- Arguments can appear in any order.

Examples:
- `/start-workday` → DMP, now
- `/start-workday 8am` → DMP, 08:00
- `/start-workday Personal` → Personal, now
- `/start-workday Personal 8am` → Personal, 08:00
- `/start-workday 8:30am DMP` → DMP, 08:30

Normalize time to 24-hour `HH:MM` format.

## Procedure

1. **Resolve time**: If no time in arguments, run `date +%H:%M` for current time.
2. **Read daily file**: `~/Vaults/Notes/0-log/worklog/YYYY/MM/YYYY-MM-DD.md`
   (today's date). Create year/month directories and file with minimal
   frontmatter if it doesn't exist.
3. **Guard**: If there's already an open segment (a `workday` entry with no
   `end`), warn the user and ask whether to close it first (set its `end` to
   now) or abort.
4. **Append segment**: Add `{client, start}` to the `workday` list in
   frontmatter. Create the `workday` list if it doesn't exist.
5. **Write file**: Update frontmatter, preserve body.
6. **Confirm**: "Clocked in for **{client}** at {time}."
