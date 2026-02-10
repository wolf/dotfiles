---
name: resume-task
description: Resume an existing task from where you left off
disable-model-invocation: true
argument-hint: "<branch-name>"
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Write, Edit, Bash(git *), Bash(cd *), Bash(ls *), mcp__things__*
---

# Resume Task

Resume an existing task from where you left off. Argument: `$ARGUMENTS` (branch name).

**Philosophy:** Read as little as possible. The pickup notes should contain everything needed to resume — don't explore the codebase until we have a specific question.

## 1. Find and Switch to Branch

```bash
git branch --list "$ARGUMENTS"
git branch --list "*$ARGUMENTS*"
```

If no match found, **stop and tell the user** — don't silently create a new branch. Suggest `/new-task` if they meant to start fresh.

If match found:
```bash
git switch <branch-name>
```

## 2. Read Pickup Notes (Minimal)

Read **only** the pickup notes — don't explore the codebase yet.

**Branch description (quick glance):**
```bash
git config branch.<branch>.description
```

**Find the TODO file** (check in order, use first found):
1. `TODO-<branch-name>.local.md`
2. `TODO.local.md`
3. `TODO.md`

**Parse the structured pickup format** (if present):
```markdown
## Pickup Notes

**Last session:** YYYY-MM-DD
**State:** [What phase of work]
**Next step:** [Specific action to resume]
**Uncommitted:** [Yes/No]
**Key files:** [Files with line numbers]
```

**Do NOT read the key files yet** — just note them for reference.

## 3. Present State Concisely

Tell the user:
- **State**: One line from pickup notes
- **Next step**: The specific action recorded
- **Uncommitted work**: Yes/no
- **Key files**: Listed but not read
- **Staleness**: How long since last session (from Last session date)

Keep it brief. Don't summarize the whole TODO — just the pickup context.

## 4. Check Things (Quick)

Search Things for tasks matching the task name. If found, note it exists — don't enumerate all checklist items unless asked.

## 5. Ask What to Do

Don't assume. Ask:

> "Ready to pick up where you left off ([next step])? Or would you prefer to:
> - Review key files first
> - See the full TODO
> - Enter plan mode to reassess"

---

## Completion

Brief summary:
- Branch: `<name>`
- State: [from pickup notes]
- Next step: [from pickup notes]
- Things: matched / no match

**Do not** list files, show directory structure, or read code unless explicitly asked.
