---
name: commute
description: Log commute time to daily work log
argument-hint: "[direction] [start-time] [end-time | duration]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, mcp__things__*, mcp__omnifocus__*
---

# Commute

Log a commute leg. Argument: `$ARGUMENTS` (direction, times or duration).

## Conventions

Read `~/Vaults/Notes/0-log/worklog/CLAUDE.md` for the canonical worklog
format — frontmatter schema, entry format, duration short forms, and client
attribution rules.

## Parse Arguments

Extract **direction** and **time/duration** from `$ARGUMENTS`:

- **Direction**: `in`, `to work`, `to livonia`, `to office` → morning commute.
  `home`, `back`, `return` → evening commute. Default: ask.
- **Time pair**: two times like `7:15am 8:30am` → compute duration from the
  delta.
- **Single duration**: `1h15m`, `45m`, `~1h` → use directly.
- If neither is provided, ask.

Examples:
- `/commute in 7:15am 8:30am` → "Commute to Livonia", 1h15m
- `/commute home 45m` → "Commute home", 45m
- `/commute to work 1h` → "Commute to Livonia", 1h
- `/commute` → ask direction and duration

## Location

Write to: `~/Vaults/Notes/0-log/worklog/YYYY/MM/YYYY-MM-DD.md`

Create year and month directories as needed.

## Entry Format

```markdown
## Commute to Livonia

Duration: 1h15m (DMP)
```

Or for the return:

```markdown
## Commute home

Duration: 45m (DMP)
```

- Always attributed to **DMP** — commute is a cost of going to the office.
- `event_type: commute` in frontmatter entries.
- No body text needed unless the user provides details.

## Frontmatter

When creating or appending to a daily file, **always read the existing file
first**, then update the YAML frontmatter to reflect all entries (including the
new one). See the worklog CLAUDE.md for the full frontmatter schema.

The entry in the frontmatter `entries` list uses `event_type: commute`:

```yaml
  - title: "Commute to Livonia"
    duration: "1h15m"
    client: DMP
    event_type: commute
    tickets: []
```

## Task Manager Integration

After adding the entry, check OmniFocus for matching tasks (e.g., "leave for work", "leave work"). If a match exists, ask if it should be marked complete or updated.
