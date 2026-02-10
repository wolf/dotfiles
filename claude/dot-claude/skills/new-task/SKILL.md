---
name: new-task
description: Start a new task with branch and TODO setup
disable-model-invocation: true
argument-hint: "<task-name>"
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Write, Edit, Bash(git *), Bash(cd *), Bash(ls *), mcp__things__*
---

# New Task

Start a new task. Argument: `$ARGUMENTS` (task name, will become branch name).

<!-- TODO: This flow needs more thought. Key questions:
  - How much to ask upfront vs. discover as we go?
  - Should it always create a TODO file, or only if multi-step?
  - When to suggest plan mode vs. just start?
-->

## 1. Check for Existing Branch

```bash
git branch --list "$ARGUMENTS"
```

If a branch with this name exists, **stop and ask**: resume that branch with `/resume-task`, or pick a different name?

## 2. Check Working Copy State

```bash
git status --short
```

If there are uncommitted changes:
- Ask: commit first, stash, or create a worktree?
- If worktree: create at `../<project>-<task>`

## 3. Create Branch

```bash
git switch -c <task-name>
```

## 4. Gather Minimal Context

**Ask the user** (don't go exploring):
- What's the objective?
- Any ticket number?
- Initial approach or constraints?

## 5. Set Branch Description

```bash
git branch --edit-description
```

One-liner format: `[Objective]: [Initial approach or constraint]`

## 6. Create TODO File

Create `TODO-<task-name>.local.md`:

```markdown
# Task: <task-name>

## Objective

[From user input]

## Steps

- [ ] [First step - ask user or suggest based on objective]

## Notes

[Any constraints or ticket reference]
```

## 7. Check Things (Quick)

Search Things for matching tasks. Note if found.

## 8. Suggest Next Action

Based on the objective:

- **Clear and small**: "Ready to start on [first step]?"
- **Unclear or large**: "This seems non-trivial. Enter plan mode to think through the approach?"
- **Needs exploration**: "Want me to explore the codebase to understand [specific thing]?"

---

## Completion

Brief summary:
- Branch: `<name>` (created)
- TODO: `TODO-<task-name>.local.md`
- Things: matched / no match
- Suggested action: [from above]

**Do not** list files, show directory structure, or read code unless explicitly asked.
