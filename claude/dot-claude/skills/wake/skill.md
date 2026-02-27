---
name: wake
description: Record wake time for envelope tracking
argument-hint: "[time]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Wake

Record what time I woke up. Argument: `$ARGUMENTS` (optional time).

## Conventions

Read `~/Vaults/Notes/0-log/worklog/CLAUDE.md` for the canonical worklog
format — frontmatter schema.

## Parse Arguments

Extract optional **time** from `$ARGUMENTS`:

- **Time**: `5:30am`, `6am`, `06:15`, etc. Default: current time via
  `date +%H:%M`.

Examples:
- `/wake` → now
- `/wake 5:30am` → 05:30
- `/wake 6am` → 06:00

Normalize time to 24-hour `HH:MM` format.

## Procedure

1. **Resolve time**: If no time in arguments, run `date +%H:%M` for current
   time.
2. **Read daily file**: `~/Vaults/Notes/0-log/worklog/YYYY/MM/YYYY-MM-DD.md`
   (today's date). Create year/month directories and file with minimal
   frontmatter if it doesn't exist.
3. **Guard**: If `wake` is already set, show the existing value and ask
   whether to overwrite.
4. **Set wake**: Add or update `wake: "HH:MM"` in the top-level frontmatter
   (not inside `workday` — this is a daily-level field).
5. **Write file**: Update frontmatter, preserve body.
6. **Confirm**: "Wake time recorded: {time}."
