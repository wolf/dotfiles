---
name: begin
description: Set up ticket, branch, and working environment for a task
argument-hint: "[task description or ticket key]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, mcp__omnifocus__*, mcp__mcp-atlassian__jira_*
---

# Begin — Task Setup

Set up everything needed to start working on a chosen task. Argument:
`$ARGUMENTS` (task description, ticket key, or triage selection).

## When to Trigger

* After triage when user picks a task
* When user says "let's work on X", "I need to fix Y"
* When intent to start new work is clear

## Prerequisite: Must Be in a Project Directory

This skill requires a git project directory. If in the Notes vault or a
non-git directory, tell the user to switch to the appropriate project
terminal first.

## 1. Ticket

Every unit of work needs a Jira ticket. **Strongly discourage working
without one.**

**If a ticket key is provided** (e.g., `SE-2930`):
* Fetch the ticket to confirm it exists and get details

**If no ticket exists**:
* Create one with defaults:
  * Project: SE
  * Assignee: Wolf (wolf@dmp-maps.com)
  * Story points: 1 (`customfield_10544`)
  * Planned finish date: today (`customfield_10724`)
* Ask for: summary (required), description (optional)
* The user can override defaults (points, priority, etc.)

**For all tickets**:
* Move to current sprint if not already there (use `jira_add_issues_to_sprint`)
* Transition to **In Progress** unless already in PR or DONE state
* Note the story points

## 2. Check for Existing Branch

Before creating anything, check if a branch already exists for this ticket:

```bash
git branch --list "*<ticket-key>*"
git branch -r --list "*<ticket-key>*"
```

Also check for branches matching the task description keywords.

**If a matching branch exists** → skip to **Step 5 (Resume)**.

**If no branch exists** → proceed to **Step 3 (New Branch)**.

## 3. New Branch

Create both branches immediately:

* **Local branch**: short, descriptive name
  * e.g., `audit-for-accidental-changes`
  * Ask the user for the name, or derive from ticket summary
* **Remote branch**: tells everything to others
  * Format: `<category>/wolf/<ticket-key>-<kebab-summary>`
  * e.g., `bugfix/wolf/SE-1234-audit-for-accidental-changes`
  * Category: infer from context
    * Bug fix → `bugfix/`
    * New capability → `feature/`
    * Urgent fix → `hotfix/`
    * Ask only if ambiguous

Commands:
```bash
git switch -c <local-branch>
git push -u origin <local-branch>:<remote-branch>
```

## 4. Resume (existing branch)

Switch to the existing branch:
```bash
git switch <branch-name>
```

Read pickup notes from (in priority order):
1. `TODO-<branch-name>.local.md`
2. `TODO.local.md`
3. Branch description (`git config branch.<name>.description`)

Present context concisely. Ask: "Pick up where you left off, or reassess?"

## 5. Ready

Confirm setup:
```
Ticket:  SE-1234 — Audit for accidental changes (1pt, In Progress)
Branch:  audit-for-accidental-changes → bugfix/wolf/SE-1234-audit-for-accidental-changes
```

If the work is non-trivial (new or resumed), suggest entering plan mode.
