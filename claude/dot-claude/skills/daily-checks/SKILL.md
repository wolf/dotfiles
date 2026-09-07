---
name: daily-checks
description: Silent dispatcher for once-per-day housekeeping checks. Fired by whichever worklog-touching skill first creates today's worklog file. Runs each check in auto mode and emits one combined status line.
argument-hint: ""
---

# Daily Checks

Single entry point for the once-per-day auto checks. No interactive/auto distinction — this skill is always the silent dispatcher.

The worklog-touching skills (`commute`, `log-meeting`, `log`, `start-workday`) invoke `/daily-checks` once, immediately after creating today's worklog file. This skill fans out to the individual checks so those four call sites never need to change again — adding a new daily check means adding a line here, nowhere else.

## Procedure

1. Invoke `/calendar-cleanup --auto`. Capture its one-line summary.
2. Invoke `/bills-due-today --auto`. Capture its one-line summary.
3. Invoke `/announcement-check --auto`. Capture its one-line summary (usually empty — it only speaks in the three days after a Runtime Arguments recording whose announcement isn't yet approved).
4. Emit the non-empty summaries combined as a single status line, separated by a space. If a check errors or produces nothing, drop it silently rather than blocking the others.

## Adding a new daily check

Add a step here that invokes the new skill's `--auto` mode and folds its summary into the combined line. Do not touch the four worklog-skill call sites — they only ever call `/daily-checks`.
