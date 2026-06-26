---
name: calendar-cleanup
description: Sweep Wolf calendars and the DMP calendar for OoO mirroring, tag-line normalization, and DMP conflict detection. Auto mode is silent and runs once per day, fired by the first worklog-touching skill that creates today's worklog file. Interactive mode (default) does the full sweep.
argument-hint: "[--auto]"
allowed-tools: Read, Write, Edit, AskUserQuestion, mcp__apple-events__calendar_events, mcp__apple-events__calendar_calendars
---

# Calendar Cleanup

Periodic maintenance sweep across personal (`Wolf (Shared)`, `Wolf (Unshared)`) and DMP (`Calendar`) calendars.

Two modes, depending on argument:

- **`--auto`**: Silent run. Mirrors out-of-office events to the DMP calendar. Surfaces a one-line summary of conflicts. **No prompts. No tag work.**
- **No argument (interactive)**: Full sweep — Pass 1 OoO mirroring + Pass 2 tag normalization (with prompts) + Pass 3 conflict resolution (with prompts).

The skill runs automatically once per day, fired by whichever worklog-touching skill first creates today's worklog file. It can also be invoked manually at any time.

## Calendars

- **Wolf calendars** — `Wolf (Shared)` and `Wolf (Unshared)`. Personal events.
- **DMP calendar** — named exactly `Calendar` (M365). Work calendar.
- **Wolf OoO mirror** — events titled exactly `Wolf OoO` on `Calendar`. Created and managed by this skill.
- **Wolf PTO block** — events titled exactly `Wolf PTO` on `Calendar`. Created manually by Wolf to mark approved PTO days. Recognized but not created by this skill.

## Lookahead window

All passes scan events from today through 14 days ahead.

## Argument parsing

If `$ARGUMENTS` contains the literal token `--auto`, run in **auto** mode. Otherwise run in **interactive** mode.

## Procedure

1. Determine mode from `$ARGUMENTS`.
2. Read events on `Wolf (Shared)` and `Wolf (Unshared)` for the lookahead window. Combine into one source list.
3. Read events on `Calendar` for the same window. Separate into three lists: Wolf OoO mirrors (title equals `Wolf OoO`), Wolf PTO blocks (title equals `Wolf PTO`), and DMP events (everything else).
4. Run **Pass 1 — OoO mirroring** (always).
5. If interactive, run **Pass 2 — Tag-line normalization**.
6. Run **Pass 3 — Conflict detection**:
   - Auto: emit single-line summary, end.
   - Interactive: walk through conflicts with the user.
7. Emit a final summary line on completion.

---

## Pass 1 — OoO mirroring (both modes; silent)

For each Wolf-calendar event whose `[startDate, endDate]` intersects ANY 8 AM – 5 PM Mon–Fri window:

1. **Weekend exclusion**: If the event's start date falls on a Saturday or Sunday → skip. Do not create OoO mirrors for weekend events.
2. **PTO suppression**: Check if the event's start date falls within any Wolf PTO block's date range. If yes → skip (the PTO block already marks Wolf as absent; an OoO mirror would be redundant noise).
3. Look up the Wolf OoO mirror list (Step 3 above) for an event whose start and end exactly match the source event's window.
4. If a matching mirror exists → skip.
5. Otherwise, create on `Calendar` via `mcp__apple-events__calendar_events` (action: `create`):
   - `targetCalendar`: `Calendar`
   - `title`: `Wolf OoO`
   - `startDate` / `endDate`: the full source-event window — do NOT clip to 8–5
   - `availability`: `unavailable` (renders as Out of Office in M365)
   - **Omit** `note`, `location`, `url`, attendees, alarms — no detail leaks.

**Intersection rule**: any overlap with work hours triggers a mirror, even partial. Example: a 7:30–8:15 personal event mirrors as a 7:30–8:15 OoO event because the 8:00–8:15 segment intersects work hours.

**Recurring source events**: in v1, mirror only the specific instances that fall in the lookahead window. Do NOT propagate recurrence rules to the mirror — each daily auto-run catches newly-entered instances.

**Track count of mirrors created** for the final summary.

---

## Pass 2 — Tag-line normalization (interactive only)

For each event on the Wolf calendars in the lookahead window:

1. Read the event's current note.
2. Inspect the first non-empty line.
3. If that line consists solely of whitespace-separated `#tag` tokens, the event is already normalized — skip silently.
4. Otherwise, infer candidate tags from the event title and any existing note content against the [tag taxonomy](#tag-taxonomy).
5. Use `AskUserQuestion` to present:
   - Event title and time window
   - Current note (or `(empty)`)
   - Proposed tag line
   - Choices: **Accept**, **Edit** (user types replacement tag line), **Skip**, **Extend taxonomy** (user adds a new tag to the canonical list for the rest of this session)
6. On Accept or Edit, update the event's note: prepend the chosen tag line + a blank line to the existing note string, then update via `mcp__apple-events__calendar_events` (action: `update`).

**Track count of tag lines added** for the final summary.

---

## Pass 3 — Conflict detection

For each Wolf-calendar event on a weekday (Mon–Fri) whose window intersects work hours (8 AM – 5 PM):

1. From the DMP-events list (Step 3 of Procedure), find any whose time window overlaps the Wolf event's window.
2. These are conflicts.

### Auto mode

Count conflicts across all Wolf events. Emit one summary line:

- If conflicts == 0: `Calendar cleanup: OoO mirrors synced (N created); no conflicts.`
- If conflicts > 0: `Calendar cleanup: OoO mirrors synced (N created); M DMP conflict(s) detected — run /calendar-cleanup to review.`

End. Do not prompt.

### Interactive mode

For each conflict, present:

- DMP event: title, time window, organizer (if available), recurrence status
- Wolf event causing the conflict: title, time window, calendar source

Then use `AskUserQuestion` with these options:

- **Keep** — do nothing.
- **Set free** — update the DMP event with `availability: "free"`, `span: "this-event"`. Best when you'll attend remotely or briefly without blocking the slot.
- **Delete this instance** — delete the DMP event with `span: "this-event"`. **Warning to display:** "This removes the event from your local calendar but does NOT notify the organizer. Use 'Open in Calendar.app' if you need a real decline."
- **Open in Calendar.app** — surface the event ID and instruct the user to decline manually in Calendar.app or Outlook (only this path triggers the actual decline-with-response).
- **Skip** — leave for a future run.

---

## Tag taxonomy

Curated starting list (open vocabulary — extensible during a run):

- `#appointment/medical` — doctor, dentist, PT, therapy, vision, etc.
- `#firearms` — generic firearms-related
- `#firearms/training` — dry-fire, live-fire training, classes
- `#firearms/competition` — matches, leagues (use alongside more specific tags)
- `#USPSA` — USPSA-specific (matches, RO duty, classifiers)

Inference: consider both the event title and any existing note content. Multiple tags on one event are fine and often correct (e.g., a USPSA classifier match earns both `#firearms/competition` and `#USPSA`). When the title strongly suggests a category not in this list, propose the new tag explicitly so the user can confirm and extend the taxonomy.

---

## Capability notes

The Apple Events MCP **cannot send a true decline response** to a meeting organizer — there's no participant-status / response-action field exposed. The skill's `Delete this instance` option removes the event from the local calendar but does NOT notify the organizer. When a real decline-with-response is needed (organizer should know you can't attend), the user must do it in Calendar.app or Outlook directly. The `Open in Calendar.app` option in the conflict prompt is the path for that case.

Limitations not addressed in v1 (flagged as future improvements):

- **Orphan mirrors**: Wolf OoO events whose source event has been deleted or moved are not cleaned up.
- **Recurrence on mirrors**: mirrors are per-instance, not pattern-based. Each daily run picks up newly-in-window instances.
- **True decline-with-response**: requires Microsoft Graph API or Outlook scripting, not Apple Events MCP.

---

## Final summary

Emit a single final line summarizing the run:

- Auto: `Calendar cleanup: OoO mirrors synced (N created); M DMP conflict(s) detected — run /calendar-cleanup to review.` (or the no-conflict variant)
- Interactive: `Calendar cleanup complete: N OoO mirrors created, T tag lines added, R conflicts resolved (S skipped).`
