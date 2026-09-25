---
name: log-audit
description: Scan the past week of worklog files for missing times and incomplete entries — gaps that live logging misses and only show up in hindsight once new times have actually landed. Auto mode is silent unless something's found; runs automatically at the end of /triage-jpr. Interactive mode (default) shows the full audit.
argument-hint: "[--auto]"
allowed-tools: Read, Bash
---

# Log Audit

Retrospective completeness check over the worklog, distinct from `daily-checks`: that dispatcher fires once, at the moment a day's file is first created — before any of that day's real times exist to check. This skill fires *after* times have landed (specifically at the end of a `/triage-jpr` run, which is exactly when a batch of new or backfilled times just landed), and looks backward for gaps that logging-in-the-moment tends to leave behind.

Two modes:

- **`--auto`**: Silent run. Emits one line only if something's found; nothing otherwise. Invoked automatically from `/triage-jpr` step 8.
- **No argument (interactive)**: Full listing of everything found, grouped by day, oldest first.

## Window

The 7 calendar days ending today, inclusive. A date with no worklog file at all is skipped silently — no file is not a gap, it's an untouched day (weekend, PTO, day off).

## Checks

For each existing file in the window, in frontmatter:

1. **Open workday segment on a past day** — a `workday` entry with `start` but no `end`, where the file's date is before today. (Today's own open segment is normal — still clocked in — never flag it.)
2. **Entries but no `wake`** — the file has one or more `entries[]` but no top-level `wake` field.
3. **`wake` with no prior night's `sleep`** — the file has `wake` set; the previous calendar day's file (if it exists) has no `sleep` field. Skip this check if the previous day's file doesn't exist at all (nothing to compare against).
4. **`duration: "unknown"` entries** — any entry whose duration literal is `"unknown"`.
5. **Unpaired commute leg** — exactly one `event_type: commute` entry on a day that also has a `workday` segment (suggesting an office day with only one leg logged). Informational only — plenty of real days are legitimately one-way (half-day, WFH switch mid-day).
6. **Stale `## Pick-up` section** — a `## Pick-up` section present on two or more consecutive days in the window without being cleared, suggesting carried-forward items aren't getting resolved.

## Auto output

One line, findings joined with `; `, oldest date first. Each finding names its date and the specific gap:

`Log audit: 2026-09-20 workday never closed (start 08:00); 2026-09-22 no bedtime logged.`

If nothing found: emit nothing (like `announcement-check`, not like `calendar-cleanup`'s explicit "no conflicts" line — this should be silent noise, not a daily "all clear").

## Interactive output

Grouped by day, oldest first, each finding as a bullet under its date. If nothing found: `No gaps found in the last 7 days.`

This mode doesn't fix anything itself — it's a report. Filing the missing time is a normal call to the relevant sibling skill (`/wake`, `/sleep`, `/start-workday`, `/end-workday`, `/commute`) with an explicit past date, same as any other backfill.
