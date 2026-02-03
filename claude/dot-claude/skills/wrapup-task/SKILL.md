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

Run `git status` to see uncommitted changes. If there are changes:
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

If work is incomplete or could be resumed later:
- Update branch description with current state: `git branch --edit-description`
- Or update/create a TODO file with next steps

**Ask:** "Is there anything specific to note for picking this up later?"

### 5. Check Things

Query today's tasks in Things (`mcp__things__get_today`) and search for matches to the current work.

- If a matching task exists, ask if it should be marked complete or have checklist items updated
- If no match, mention this (user may want to track differently)

## Completion

Summarize what was done:
- Commit status
- Worklog entry location
- Any documentation updates
- Things task status
- Pickup notes location (if applicable)
