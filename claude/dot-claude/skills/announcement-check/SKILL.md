---
name: announcement-check
description: Post-recording nudge to draft and approve the Runtime Arguments episode announcement. Auto mode is silent unless a recording was logged in the last 3 days without an approved draft, and runs as part of /daily-checks. Interactive mode (default) reports the last week.
argument-hint: "[--auto]"
allowed-tools: Read, Bash, Glob
---

# Announcement Check

Detects that a Runtime Arguments episode was recorded yesterday and nudges toward drafting and approving its Mastodon announcement while the episode is fresh. Read-only; never edits the worklog.

Why day-after: episodes record Thursday and publish Saturday 15:00. The transcript and show notes reach Buzzsprout on recording day or the next, so the day after recording is the earliest the draft can be written and the last comfortable moment before the publish window. See `~/Vaults/Notes/3-areas/runtime-arguments/announcement-automation.md`.

Two modes, depending on argument:

- **`--auto`**: Silent run. Emits one line only if a recording was logged in the last 3 days (yesterday, two days ago, or three days ago) and its announcement isn't yet approved; otherwise emits nothing. No prompts.
- **No argument (interactive)**: Reports any recording in the last 7 days and whether an announcement draft exists for it.

## Argument parsing

If `--auto` contains the literal token `--auto`, run in **auto** mode. Otherwise run in **interactive** mode.

## Detection

A worklog day counts as a recording day if its frontmatter `entries[]` contains an item with `client: RuntimeArguments` and a `title` beginning `Recording` (case-insensitive). Worklog files live at `~/Vaults/Notes/0-log/worklog/YYYY/MM/YYYY-MM-DD.md`.

A draft exists for the recording if any file under `~/Vaults/Notes/3-areas/runtime-arguments/` matches `ep-*-announcement.md` and was modified on or after the recording date. Treat a draft with frontmatter `approved: true` as approved.

## Procedure

1. Resolve the candidate dates: auto mode uses the last 3 days (`date -v-1d`, `-v-2d`, `-v-3d`, each `+%Y-%m-%d`); interactive mode uses the last 7. Never include today — today's file is the one being created when this runs.
2. Read each existing worklog file in that window, newest first, and stop at the first one with a recording entry. Missing files are skipped, not errors.
3. If a recording is found, look for a matching draft per Detection.

The 3-day auto window exists so a Thursday recording still nudges on Saturday if no worklog file was created Friday. Saturday is publish day, so three days back is the last useful moment.

## Auto output

Exactly one line when a recording was found in the window, otherwise nothing. Name the day relative to today (`yesterday`, `Thursday`, etc.):

- No draft: `Runtime Arguments: recorded <day> — draft and approve the announcement? (/announce-episode, or by hand in the episode folder)`
- Draft exists, not approved: `Runtime Arguments: announcement draft for <day>'s recording exists — review and set approved: true.`
- Draft approved: emit nothing.

## Interactive output

For each recording day found in the last 7 days: the date, the entry title, and the draft state (none / drafted / approved). If none: `No Runtime Arguments recording in the last 7 days.`

## Notes

`/announce-episode` is planned (step 4 of the automation plan) and does not exist yet. Until it does, the nudge still applies — the draft is written by hand into the episode folder, following the format in `3-areas/runtime-arguments/CLAUDE.md`.
