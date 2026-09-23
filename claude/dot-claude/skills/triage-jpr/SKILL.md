---
name: triage-jpr
description: Extract and triage Just Press Record voice-note transcripts. Unambiguous wake/sleep/commute/meeting notes file automatically; everything else confirms its destination; each recording is deleted once filed. Invoke proactively when the user asks to process, triage, or go through their voice notes, recordings, or JPR, or on /triage-jpr.
argument-hint: ""
allowed-tools: Read, Write, Edit, Glob, Bash, AskUserQuestion, mcp__omnifocus__*
---

# Triage JPR Voice Notes

Extract transcripts from Just Press Record (JPR) recordings and file their content across the vault, OmniFocus, and the worklog — auto-filing what's unambiguous, confirming everything else, and deleting each recording only once every topic it holds has been resolved.

## Conventions

Read `~/Vaults/Notes/0-log/worklog/CLAUDE.md` for the canonical worklog format, and `~/Vaults/Notes/3-areas/public-writing/CLAUDE.md` for that area's frontmatter conventions.

## 1. Scan

Run `~/.claude/skills/triage-jpr/scripts/jpr-recordings.py scan`. It returns a JSON array, oldest first, each entry `{path, recorded_at, status, transcript, detail}` with `status` one of `ready`, `downloading`, `untranscribed`, `unreadable`.

Before showing anything, read the last few days' worklog files (`0-log/worklog/YYYY/MM/YYYY-MM-DD.md`) for a "Triage N Just Press Record voice notes" entry, and note which recordings' topics that entry says were left pending (see step 8) — those topics are already filed and should be treated as resolved, not re-filed.

Show a plain-text overview before touching anything: every `ready` recording's timestamp and transcript, oldest first, then the `downloading`, `untranscribed`, and `unreadable` buckets named by timestamp. If nothing is `ready`, report the buckets and stop.

## 2. Own today's worklog and the daily hook

If anything is `ready`, ensure today's worklog file exists (minimal frontmatter, per the worklog CLAUDE.md). If this step just created it, invoke `/daily-checks` right now.

A triage run almost always touches today — at minimum, the closing triage `/log` entry in step 8 lands there. Doing this up front means the checks fire once, at the start of the run, rather than depending on which sibling skill happens to create the file first. Because today's file now already exists, and every sibling invocation in this skill passes an explicit date (step 6), none of them will re-trigger `/daily-checks` for today, and a past-dated sibling invocation never triggers it at all — see each sibling's own rule.

## 3. Classify the whole batch, and group related recordings

Split each recording into its **topics** — wake, bedtime, a commute leg, a meeting, an investigation idea, a thought, work time, a public-writing idea, a personal-action item. One recording commonly holds several.

Recordings that amend, correct, or continue one another share a topic and form one **item**: e.g. "ended my workday at 4pm" followed by "sorry, make that 4:30pm" is one `/end-workday` item at 16:30. Commute start and arrival notes pair the same way. File an item once, with its final values.

A correction to something already filed in an **earlier** run (its source recording already deleted) is applied as an update to the existing worklog value — show old → new before changing it.

Note any conflict that can't be reconciled here, before filing anything, rather than discovering it mid-item.

## 4. Auto-file when unambiguous (no confirmation)

For wake, bedtime, commute, and meeting topics, invoke the sibling skill directly, the way `daily-checks/SKILL.md` invokes its checks — no confirmation, because the worklog format is rigid and the transcript either states the fact clearly or it doesn't:

* wake → `/wake`
* bedtime → `/sleep`. **A bedtime belongs on the file of the day it closes** — the day whose `wake` precedes it, not the day whose wake follows it. Resolve the actual bedtime moment: the latest occurrence of that clock time before the recording's timestamp. If that moment is before 12:00 noon, file it on the **previous** calendar date; otherwise file it on its own date. This matches the worklog dashboard's own noon cutoff (a page's `sleep` pairs with the *next* page's `wake` for duration, and a `sleep` before noon is treated as after-midnight of that same page's night). Example: a recording at 2026-09-23 05:19 saying "went to bed at 12:20" → `sleep: "00:20"` on **2026-09-22**, not 2026-09-23.
* commute → `/commute` (pair start and arrival legs across the batch into one duration)
* workday start/end → `/start-workday` / `/end-workday`
* meeting → `/log-meeting`

Stop and ask only when something is genuinely unclear: a garbled time, an uncertain day, a conflict within the batch, or a value already set in the worklog that this would overwrite.

## 5. Confirm the destination for everything else

One recording (or item) at a time. When the dictation is garbled, ask what it actually means before proposing a destination — never guess at a plausible-sounding interpretation. The reason to confirm here isn't that the classification is unclear; it's that the destination rarely has one obvious answer, and the raw dictation often needs cleanup before it's fileable.

* "investigate X" technical-curiosity ideas → an OmniFocus task in the **Investigations** project (Development folder), tagged `investigation`, plus `DMP` when it's DMP-related work. Never a vault note.
* a fleeting reflection → `/thought`, verbatim
* general session or external work time → `/log`
* a public-writing post idea (gear, competition, holster content meant for eventual publication) → draft or append under `~/Vaults/Notes/3-areas/public-writing/`, following that area's frontmatter convention
* a gear, shopping-list, or target-practice-benchmark personal-action item → an OmniFocus task in the relevant existing project (ask which one if it isn't obvious)
* anything else ambiguous → ask, don't guess

If a topic should be postponed rather than filed now, offer to park it verbatim as an OmniFocus inbox task — that counts as resolved for step 7's purposes.

## 6. Dates

Every sibling invocation in step 4 and step 5 passes the date the content belongs to: the recording's own date, or the bedtime rule above when it applies. `/wake`, `/commute`, `/start-workday`, and `/end-workday` take a trailing date argument; `/log`, `/log-meeting`, and `/thought` take `--date=` (see each skill's own argument parsing).

## 7. Delete per item

Right after one item (a single recording, or a related group from step 3) is fully filed — every topic across its recording(s) either auto-filed, filed after confirmation, or explicitly parked as an OmniFocus task — run `jpr-recordings.py delete <path>...` for every recording in that item at once. An item with any topic still undecided keeps all of its recordings; delete only ever happens whole, never partial.

## 8. Worklog note

Log the triage itself via `/log` as a `Triage N Just Press Record voice notes` entry (where N is the count of recordings deleted this run), matching the tone of the 2026-09-21 through 2026-09-23 worklog entries:

* attribution `(Personal)` or `(Personal/DMP)` depending on what was filed
* a one-paragraph body naming the worklog entries filed, the OmniFocus tasks and tickets created, and any public-writing drafts touched
* "Deleted N processed recordings from iCloud."
* the timestamps of any recordings left in the `downloading`, `untranscribed`, or `unreadable` buckets
* for any recording kept because one of its topics is still undecided: its timestamp, which topics were already filed, and which one is pending — this is what step 1 reads back on the next run to avoid re-filing

## 9. Non-goals

* Don't parse the `sd` word-timing array — it isn't in `scan`'s output at all.
* Don't rely on the JPR app's own export feature — it's broken; `scan` reads the `.m4a` files directly.
* Don't confirm the unambiguous wake/sleep/commute/meeting cases in step 4 — that's friction, not safety.
* Don't bulk-delete across items — each item's recordings are deleted only once that item is fully resolved.
* Don't delete anything in the `downloading`, `untranscribed`, or `unreadable` buckets.
