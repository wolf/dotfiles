---
name: deliver
description: Ship completed work — direct release or PR
argument-hint: "[release or pr]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, mcp__omnifocus__*, mcp__mcp-atlassian__jira_*, mcp__atlassian-bitbucket__*
---

# Deliver — Ship Completed Work

Ship the current branch's work via direct release or pull request. Argument:
`$ARGUMENTS` (optional: "release" or "pr" to skip the question).

## When to Trigger

* User says "this is ready", "ship it", "let's PR this", "I think this is done"
* Proactively when tests pass and work looks complete: "Ready to deliver?"

## Prerequisite Checks

Before proceeding:
1. Confirm we're on a feature branch (not main or release)
2. All tests pass (run the project's test suite)
3. Working tree is clean (all changes committed)
4. Identify the Jira ticket from the remote branch name or ask

## Choose Path

If not specified in `$ARGUMENTS`, ask:

> "Direct release or PR?"
> * **Direct release** — merge to main (+ release), tag, push, done
> * **PR** — push, create PR on Bitbucket, move ticket to review

---

## Direct Release Path

### 1. Prepare

```bash
git fetch origin
git rebase origin/main
```

Run tests again after rebase to confirm nothing broke.

### 2. Merge

```bash
git switch main
git merge --ff-only <feature-branch>
```

Unless told otherwise, also merge to release:
```bash
git switch release
git merge --ff-only main
git switch main
```

### 3. Update CHANGELOG

**Decide the version number before starting delivery.** The version determines
the CHANGELOG heading and the tag.

If the project has a `CHANGELOG.md`, add an entry for the new version at the
top of the file (below the header). Follow the existing format. Include:

* **Features** — user-visible additions
* **Bug fixes** — what broke and what was fixed
* **Deprecations** — what to stop using and the replacement
* **Migration** — what users need to change (if anything)
* **Internal** — significant performance or structural changes (keep high-level)
* **Breaking** — called out explicitly when applicable

Omit empty sections. Derive content from the commits being shipped. Use today's
date.

**Single-commit releases:** When the release is a single logical commit (still
on the feature branch, not yet merged), include the CHANGELOG update in that
commit — amend it or add it before merging. This keeps the release atomic: one
commit, one tag, one entry. Do not create a separate CHANGELOG commit.

**Multi-commit releases:** Commit the CHANGELOG update on the current branch
(after merging) before tagging:
```bash
git add CHANGELOG.md
git commit -m "Add v<version> changelog entry"
```

### 4. Tag

Discover the current version tag and suggest the next version:
```bash
git tag --sort=-v:refname | head -5
```

Report the current version and suggest patch/minor/major bumps (e.g., "Current: v1.2.3 — bump to v1.2.4 / v1.3.0 / v2.0.0?"). Default suggestion should match the scope of the change. Use annotated tags:
```bash
git tag -a v<version> -m "<summary>"
```

### 5. Push

```bash
git push origin main release --tags
```

### 6. Cleanup

* Delete local feature branch: `git branch -d <feature-branch>`
* Delete remote feature branch: `git push origin --delete <remote-branch>`
* If a worktree exists for this branch, remove it:
  `git worktree remove ../<worktree-dir>`
* Move Jira ticket to **DONE** (use `jira_transition_issue`)
* Delete matching OmniFocus task if one exists
* Delete matching entry in `inbox.local-only.md` or TODO file if one exists
* Log effort in worklog (trigger **log** skill)

---

## PR Path

### 1. Update CHANGELOG

If the project has a `CHANGELOG.md`, add an entry for the new version at the
top of the file (below the header). Follow the existing format. Include:

* **Features** — user-visible additions
* **Bug fixes** — what broke and what was fixed
* **Deprecations** — what to stop using and the replacement
* **Migration** — what users need to change (if anything)
* **Internal** — significant performance or structural changes (keep high-level)
* **Breaking** — called out explicitly when applicable

Omit empty sections. Derive content from the commits on this branch.

To determine the version number, discover the current version tag and suggest
the next version:
```bash
git tag --sort=-v:refname | head -5
```
Report the current version and suggest patch/minor/major bumps. Default
suggestion should match the scope of the change. Use today's date.

Commit the CHANGELOG update on the feature branch:
```bash
git add CHANGELOG.md
git commit -m "Update CHANGELOG for v<version>"
```

### 2. Push

Ensure all commits are pushed:
```bash
git push origin
```

### 3. Update Jira

Add notable findings to the ticket:
* Typically as a new comment (use `jira_add_comment`)
* Occasionally by updating the description
* Rarely by changing the summary

Include: what the change does, any important implementation decisions, and
things reviewers should pay attention to.

### 4. Create PR

Create a Bitbucket PR targeting **main**:

```bash
bb post /repositories/{workspace}/{repo}/pullrequests
```

The PR description should:
* Reference the Jira ticket (e.g., "Resolves SE-1234")
* Explain the problem or desired feature
* Highlight salient implementation points
* Be succinct

### 5. Rename Local Branch

Add `pr/` prefix to indicate this branch is in review:
```bash
git branch -m <local-branch> pr/<local-branch>
```

### 6. Transition Ticket

Move Jira ticket to **PR** state (use `jira_transition_issue`).

### 7. Cleanup (partial)

* Delete matching OmniFocus task if one exists
* Delete matching entry in `inbox.local-only.md` or TODO file if one exists
* **Keep worktree** if one exists — it stays until the PR is merged
* Log effort in worklog (trigger **log** skill)

---

## Branching Model Reference

* **main**: development branch. Pretty-good code. Rarely rewritten.
* **release**: production branch. Only quality code. Tagged releases here.
  Never rewritten.
* Usually main and release point to the same commit.
* PRs target main.
* Rebase preferred over merge.
* **Each commit must stand alone**: a checkout of any commit should run and
  pass all tests. Use squash, interactive rebase, and commit splitting to
  maintain this before delivering.

## Branch Category Inference

Infer the category from context for the remote branch name:
* Bug fix, broken behavior, regression → `bugfix/`
* New capability, enhancement, feature → `feature/`
* Urgent production fix → `hotfix/`
* Ask only when genuinely ambiguous
