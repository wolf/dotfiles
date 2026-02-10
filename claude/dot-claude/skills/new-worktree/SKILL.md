---
name: new-worktree
description: Create git worktree for a task
disable-model-invocation: true
argument-hint: "[task-name]"
allowed-tools: Bash(git *), Bash(cd *), Bash(ls *), Bash(pwd), Write
---

# Create Git Worktree

Create a new git worktree for isolated task work. Argument: `$ARGUMENTS` (task name).

## Naming Conventions

- **Branch name**: `$ARGUMENTS` (e.g., `add-user-auth`)
- **Worktree directory**: `<project>-<task>` in the parent directory

Example: If in `/Users/wolf/develop/myproject` with task `fix-bug`:
- Branch: `fix-bug`
- Worktree: `/Users/wolf/develop/myproject-fix-bug`

## Steps

### 1. Get Current Project Name

```bash
basename $(pwd)
```

### 2. Create Branch and Worktree

```bash
git worktree add ../<project>-<task> -b <task>
```

### 3. Set Branch Description

In the new worktree, set a description:

```bash
cd ../<project>-<task>
git branch --edit-description
```

Include the task objective and any relevant context.

### 4. Create Task TODO

Create `TODO-<task>.local.md` in the worktree root:

```markdown
# Task: <task-name>

## Objective

[To be filled in]

## Steps

- [ ] ...

## Notes

```

### 5. Remind About .gitignore

Ensure `*.local.md` is in `.gitignore` so task TODOs aren't committed.

## Completion

Report:
- Worktree location
- Branch name
- TODO file created
- Suggest: `cd ../<project>-<task>` to start working
