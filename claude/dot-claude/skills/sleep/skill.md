---
name: sleep
description: Record bedtime for envelope tracking
argument-hint: "[time]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Sleep

Record what time I'm going to bed. Argument: `$ARGUMENTS` (optional time).

## Conventions

Read `~/Vaults/Notes/0-log/worklog/CLAUDE.md` for the canonical worklog
format — frontmatter schema.

## Parse Arguments

Extract optional **time** and optional **date** from `$ARGUMENTS`:

- **Time**: `8:30pm`, `9pm`, `21:15`, etc. Default: current time via
  `date +%H:%M`.
- **Date**: `yesterday`, `2026-02-25`, `monday`, etc. Default: **yesterday**.

Examples:
- `/sleep` → yesterday, now
- `/sleep 9pm` → yesterday, 21:00
- `/sleep 9pm today` → today, 21:00
- `/sleep 10pm 2026-02-25` → 2026-02-25, 22:00

Normalize time to 24-hour `HH:MM` format. Resolve date to `YYYY-MM-DD`.

**Why yesterday?** This skill is almost always invoked the morning after —
"I went to sleep at 10pm" means last night. The only time you'd want today
is recording it right before bed, which requires the explicit `today` keyword.

## Procedure

1. **Resolve time**: If no time in arguments, run `date +%H:%M` for current
   time.
2. **Resolve date**: If no date in arguments, use **yesterday's** date.
   Resolve relative dates (`yesterday`, `today`, weekday names) to
   `YYYY-MM-DD`.
3. **Read daily file**: `~/Vaults/Notes/0-log/worklog/YYYY/MM/YYYY-MM-DD.md`
   (resolved date). Create year/month directories and file with minimal
   frontmatter if it doesn't exist.
3. **Guard**: If `sleep` is already set, show the existing value and ask
   whether to overwrite.
4. **Set sleep**: Add or update `sleep: "HH:MM"` in the top-level frontmatter
   (not inside `workday` — this is a daily-level field).
5. **Write file**: Update frontmatter, preserve body.
6. **Confirm**: "Bedtime recorded: {time} on {date}."
