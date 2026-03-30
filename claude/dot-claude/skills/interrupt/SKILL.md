---
name: interrupt
description: Pause current work with pickup notes when something urgent comes in
argument-hint: "[reason]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Interrupt — Pause Current Work

Cleanly pause the current task when something urgent comes in. Argument:
`$ARGUMENTS` (optional reason for interruption).

## When to Trigger

* User says "something came up", "I need to switch", "pause this",
  "this is being interrupted"
* User indicates urgency that requires dropping current work

## 1. Capture State

Ask the user:
* **What were you in the middle of?** (pre-fill from session context if
  obvious)
* **What's the next step when you come back?**
* **Any mental context that won't be obvious from the code?** (deferred
  decisions, things you were about to try, why you stopped here)

## 2. Write Pickup Notes

Find or create the TODO file:
1. `TODO-<branch-name>.local.md` (preferred — branch-specific)
2. `TODO.local.md` (fallback)

Write/update a `## Pickup Notes` section with structured format:

```markdown
## Pickup Notes

**Last session**: [date, brief description of what was done]
**State**: [where things stand — what's working, what's broken]
**Next step**: [the immediate next action to take]
**Uncommitted**: [description of any uncommitted changes]
**Key files**: [files that are relevant to resume]
**Mental context**: [anything that won't be obvious from the code]
```

Also update the branch description:
```bash
git branch --edit-description
```
(Set it to a one-liner: `[State]: [Next step]`)

## 3. Handle Work-in-Progress

Ask: "Want to commit the current state before switching?"

* If yes: stage and commit with a WIP message (e.g., `WIP: <description>`)
* If no: leave changes uncommitted (they'll be on this branch)

## 4. Switch Away

```bash
git switch main
```

Then offer: "Want to triage the interrupting work, or are you handling it
yourself?"
