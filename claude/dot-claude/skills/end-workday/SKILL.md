---
name: end-workday
description: Clock out — stop tracking workday hours
argument-hint: "[time]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# End Workday

Clock out of the current workday segment. Argument: `$ARGUMENTS` (optional time).

## Conventions

Read `~/Vaults/Notes/0-inbox/worklog/CLAUDE.md` for the canonical worklog
format — frontmatter schema, workday tracking rules.

## Parse Arguments

Extract optional **time** from `$ARGUMENTS`:

- **Time**: `5pm`, `17:00`, `5:30pm`, etc. Default: current time via
  `date +%H:%M`.

Normalize time to 24-hour `HH:MM` format.

## Procedure

1. **Resolve time**: If no time in arguments, run `date +%H:%M` for current time.
2. **Read daily file**: `~/Vaults/Notes/0-inbox/worklog/YYYY/MM/YYYY-MM-DD.md`
   (today's date). Error if the file doesn't exist — nothing to clock out of.
3. **Find open segment**: Look for a `workday` entry with no `end`.
   - If none: warn "No open workday segment to close." and stop.
   - If multiple (shouldn't happen): ask the user which to close.
4. **Close segment**: Set `end` on the open segment.
5. **Compute duration**: `end - start` in decimal hours (e.g., 08:00→17:00 = 9h).
6. **Write file**: Update frontmatter, preserve body.
7. **Confirm**: "Clocked out of **{client}** at {time} ({duration})."
