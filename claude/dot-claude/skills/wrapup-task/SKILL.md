---
name: wrapup-task
description: Wrap up current task - commit, worklog, document, prepare for pickup
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Bash(git *), Bash(cd *), mcp__things__*
---

# Wrap Up Current Task

Complete the current unit of work with proper documentation and handoff.

## Steps

### 1. Check Git Status

Run `git status` and `git diff --stat` to see uncommitted changes. If there are changes:
- Ask if the user wants to commit now
- If yes, follow the standard commit flow (staged changes, meaningful message)
- If no, note that uncommitted work exists

### 2. Update Work Log

Add an entry to `~/Vaults/Notes/0-inbox/worklog/YYYY/MM/YYYY-MM-DD.md` (create directories as needed).

**Ask the user for:**
- **Description**: What was accomplished (if not obvious from context)
- **Duration**: How long did this task take?
- **Ticket**: Is this related to a ticket (Jira, GitHub issue)? Note number and summary.
- **Attribution**: Who is this work for? Check for project-specific CLAUDE.md attribution rules first. If none, ask.

**Format:**
```markdown
## Task Description

Ticket: PROJ-123 - Summary of the ticket
Duration: 2h (ClientName)
```

### 3. Check for Undocumented Patterns

Scan recent work for:
- New conventions or patterns worth documenting
- Decisions that should be recorded in CLAUDE.md or project docs
- Gotchas discovered that future sessions should know

Ask if any should be persisted.

### 4. Write Pickup Notes

If work is incomplete or could be resumed later, write structured pickup notes.

#### 4a. Find or Create TODO File

Look for existing task TODO:
1. `TODO-<branch-name>.local.md` in project root
2. `TODO.local.md` in project root
3. `TODO.md` in project root

If none exists and work is incomplete, create `TODO-<branch-name>.local.md`.

#### 4b. Auto-Generate Context

Gather information automatically:

```bash
# Current branch
git branch --show-current

# Recent commits on this branch (not on main/master)
git log main..HEAD --oneline 2>/dev/null || git log master..HEAD --oneline 2>/dev/null || git log -5 --oneline

# Uncommitted changes
git status --short

# Files changed in this session (staged + unstaged)
git diff --name-only HEAD 2>/dev/null
git diff --name-only --cached 2>/dev/null
```

#### 4c. Draft Pickup Notes

Write a `## Pickup Notes` section (replace if exists) with:

```markdown
## Pickup Notes

**Last session:** YYYY-MM-DD
**State:** [One line: what phase of work — e.g., "Debugging token refresh", "Tests passing, ready for review", "Blocked on API design decision"]
**Next step:** [Specific action to resume — not "continue working" but "Add logging to refresh_token() and test under load"]
**Uncommitted:** [Yes/No — if yes, brief description]
**Key files:** [Files actively being worked on, with line numbers if relevant]
```

#### 4d. Ask for Mental Context

After drafting, ask:

> "Here's what I captured from git. Anything to add about:
> - What you were thinking or investigating?
> - Decisions you deferred?
> - Why you're stopping here?"

Incorporate the response into the pickup notes.

#### 4e. Update Branch Description

Also update the branch description with a one-liner for quick reference:

```bash
git branch --edit-description
```

Format: `[State]: [Next step]` — e.g., "Debugging: Add logging to refresh_token()"

### 5. Check Things

Query today's tasks in Things (`mcp__things__get_today`) and search for matches to the current work.

- If a matching task exists, ask if it should be marked complete or have checklist items updated
- If no match, mention this (user may want to track differently)

## Completion

Summarize what was done:
- Commit status (committed / uncommitted changes remain)
- Worklog entry location
- Any documentation updates
- Pickup notes location and summary
- Things task status
- Branch description updated

**Final prompt:** "Ready to switch tasks, `/compact` the context, or `/clear` for a fresh start?"
