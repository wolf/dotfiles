---
name: triage
description: Find what to work on next — pulls from Jira, OmniFocus, and local inbox/TODO
argument-hint: "[area or focus]"
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion, mcp__omnifocus__*, mcp__mcp-atlassian__jira_search, mcp__mcp-atlassian__jira_get_*
---

# Triage — What's Next?

Answer "what should I work on next?" by pulling from Jira, OmniFocus, and
local project files. Argument: `$ARGUMENTS` (optional area/focus filter).

## When to Trigger

* Proactively at session start in a project directory
* When the user asks "what's next?", "what should I work on?"
* After completing a task, offer to triage the next one

## Context Awareness

Determine scope from the environment:

* **In a project directory** (e.g., `~/develop/db-handles`): scope results to
  that project/area. The project name is `basename $PWD`.
* **In Notes vault** (`~/Vaults/Notes`): show everything — no area filter.
* **Explicit argument**: `$ARGUMENTS` overrides directory inference (e.g.,
  `/triage stepwise` scopes to stepwise regardless of current directory).

## Sources

Pull from three sources in parallel:

### 1. Jira

Search for current sprint tickets assigned to me:

```
assignee = currentUser() AND sprint in openSprints() ORDER BY status DESC, priority ASC
```

* Show **In Progress** tickets first (these are already started)
* Then by priority (P1 highest → P4 lowest)
* When scoped to an area, filter results to tickets whose summary or
  component relates to the area name
* Show: ticket key, summary, status, priority, story points

### 2. OmniFocus

Search for available tasks. When scoped to an area:
* Look for a folder or project matching the area name
* Show tasks within that scope that are available today

When unscoped:
* Show flagged + available tasks (today's work)

Show: task name, project, due date (if any), flagged status

### 3. Local Files

Check the current project directory for:
* `inbox.local-only.md` — cross-project incoming items
* `TODO.md` or `TODO.local.md` — task list
* `TODO-*.local.md` — branch-specific task files

Show any actionable items found.

## Presentation

Present a unified, prioritized list. Group by source but keep it scannable:

```
## In Progress (Jira)
1. SE-2930 — Fix incorrect fastmath default (P2, 1pt)

## Sprint Backlog (Jira)
2. SE-2931 — Add benchmarking to dmp-coord (P3, 2pt)

## OmniFocus
3. Review dmp-bspline test coverage (flagged, due today)

## Inbox
4. Investigate coord perf regression (from inbox.local-only.md)
```

Then ask: "Which one, or something new?"

## After Selection

Once the user picks a task (or decides on something new), trigger the
**begin** skill to set up the working environment.
