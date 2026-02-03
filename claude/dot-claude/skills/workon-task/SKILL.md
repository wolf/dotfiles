---
name: workon-task
description: Start new task or resume existing one
disable-model-invocation: true
argument-hint: "[task-name]"
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Write, Edit, Bash(git *), Bash(cd *), Bash(ls *), mcp__things__*
---

# Work On Task

Start a new task or resume an existing one. Argument: `$ARGUMENTS` (task name or branch name).

## Determine Task Type

First, check if `$ARGUMENTS` matches an existing branch:

```bash
git branch --list "$ARGUMENTS"
git branch --list "*$ARGUMENTS*"
```

If a match exists, this is a **resume**. Otherwise, this is a **new task**.

---

## Resuming an Existing Task

### 1. Switch to the Branch

```bash
git switch <branch-name>
```

### 2. Read Pickup Notes

Gather context from:
- **Branch description**: `git config branch.<branch>.description`
- **TODO files**: Look for `TODO.md`, `TODO.local.md`, `TODO-<task>.local.md`
- **Recent commits**: `git log --oneline -10`

### 3. Summarize State

Tell the user:
- What the task is about (from branch description or TODO)
- Where we left off
- What remains to be done

### 4. Check Things

Search Things for tasks matching the task name. If found, note any relevant checklist items or context.

### 5. Suggest Next Steps

Based on the pickup notes, suggest whether to:
- Continue where we left off
- Enter plan mode to reassess
- Review specific files first

---

## Starting a New Task

### 1. Check Working Copy State

Run `git status`. If there are uncommitted changes:
- Ask if the user wants to commit first, stash, or create a worktree
- If worktree: create at `<project-name>-<task-name>` in the parent directory

### 2. Create Branch

```bash
git switch -c <task-name>
```

Branch naming: Use the task name directly (e.g., `add-user-auth`, `fix-login-bug`).

### 3. Set Branch Description

```bash
git branch --edit-description
```

Include:
- Brief description of what this task will accomplish
- Any relevant ticket numbers
- Initial approach or constraints

### 4. Create TODO File

Create `TODO-<task-name>.local.md` in the project root with:
- Task objective
- Initial steps or approach
- Any open questions

Note: `.local.md` files should be git-ignored for short-lived task planning.

### 5. Check Things

Search Things for tasks matching the task name. Note any related items.

### 6. Suggest Plan Mode

If the task seems non-trivial (involves multiple files, architectural decisions, or unclear scope):

"This looks like a non-trivial task. Would you like to enter plan mode to think through the approach before coding?"

---

## Completion

Summarize the setup:
- Branch name and status
- Worktree location (if created)
- TODO file location
- Related Things tasks
- Recommendation for next step (plan mode vs. dive in)
