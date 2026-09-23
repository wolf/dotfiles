---
name: wake
description: Record wake time for envelope tracking
argument-hint: "[time] [date]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Wake

Record what time I woke up. Argument: `$ARGUMENTS` (optional time).

## Conventions

Read `~/Vaults/Notes/0-log/worklog/CLAUDE.md` for the canonical worklog
format — frontmatter schema.

## Parse Arguments

Extract optional **time** and optional **date** from `$ARGUMENTS`:

- **Time**: `5:30am`, `6am`, `06:15`, etc. Default: current time via
  `date +%H:%M`.
- **Date**: `yesterday`, `2026-02-25`, `monday`, etc. Default: **today**.

Examples:
- `/wake` → today, now
- `/wake 5:30am` → today, 05:30
- `/wake 6am yesterday` → yesterday, 06:00

Normalize time to 24-hour `HH:MM` format. Resolve date to `YYYY-MM-DD`.

## Procedure

1. **Resolve time**: If no time in arguments, run `date +%H:%M` for current
   time.
2. **Resolve date**: If no date in arguments, use today's date. Resolve
   relative dates (`yesterday`, weekday names) to `YYYY-MM-DD`.
3. **Read daily file**: `~/Vaults/Notes/0-log/worklog/YYYY/MM/YYYY-MM-DD.md`
   (resolved date). Create year/month directories and file with minimal
   frontmatter if it doesn't exist.
4. **Guard**: If `wake` is already set, show the existing value and ask
   whether to overwrite.
5. **Set wake**: Add or update `wake: "HH:MM"` in the top-level frontmatter
   (not inside `workday` — this is a daily-level field).
6. **Write file**: Update frontmatter, preserve body.
7. **Confirm**: "Wake time recorded: {time}" (add "on {date}" when the date
   isn't today).
