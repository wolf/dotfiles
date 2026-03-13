---
name: ship
description: "Ship current work: commit, push, create PR, update Jira ticket. Use after code is complete and tests pass. DMP/SE projects only."
disable-model-invocation: true
argument-hint: "[SE-XXXX]"
allowed-tools: Read, Grep, Glob, Edit, Write, Bash(git *), Bash(cd *), Bash(ls *), Bash(uv run *), mcp__mcp-atlassian__jira_*, mcp__atlassian-bitbucket__bb_*
---

# Ship

Ship the current work to a PR with full Jira integration.

**Argument:** `$ARGUMENTS` — optional Jira ticket key (e.g., `SE-2899`). If omitted, create a new ticket.

Read `~/develop/dmp/CLAUDE.md` for Jira field IDs, transition IDs, sprint lookup, and branch naming conventions.

## 0. Preflight

Verify we're in a DMP project (`~/develop/dmp/`). If not, **stop** — this skill is DMP/SE-specific.

Run `git status --short` and `git diff --stat` to understand what's changed. If there are no changes to ship, **stop**.

Check which branch we're on. Note the base branch (typically `release` or `main` depending on project's CLAUDE.md).

## 1. Ticket

**If a ticket key was provided** (`$ARGUMENTS` is not empty):

* Fetch the ticket with `jira_get_issue` to confirm it exists and get the summary.
* Use the existing summary for branch naming and PR title.

**If no ticket key was provided:**

* Ask the user for:
  * **Summary** (becomes ticket title)
  * **Description** (ticket body — can be brief, expand from context if helpful)
  * **Story points** (suggest a number, let user override)
* Create the ticket in the SE project. Set assignee, priority (default P3), planned finish date (default: end of active sprint), and story points.
* After creation, add it to the active sprint (look up with `jira_get_sprints_from_board`, board `57`, state `active`). Sprint is set via `jira_update_issue` with `customfield_10004`.

Record the ticket key (e.g., `SE-2899`) and summary for subsequent steps.

## 2. Branch

**Ask the user for:**

* **Category**: `feature`, `bugfix`, or `hotfix` (suggest based on context — new code is usually `feature`, fixing broken behavior is `bugfix`)
* **Local branch name**: suggest a short kebab-case name derived from the summary

Derive the remote branch name: `<category>/wolf/<ticket-key>-<kebab-summary>`

If not already on a feature branch, create one off the current branch:

```bash
git switch -c <local-name>
```

## 3. Commit

Stage the relevant files. Prefer naming specific files over `git add -A`. Show the user what will be staged and confirm.

Commit with an imperative-mood message. Include the ticket key in the commit body:

```
Short summary of what changed

SE-XXXX

Optional longer explanation of why.
```

If pre-commit hooks fail, fix the issue and create a **new** commit (never amend).

## 4. Push

Push the local branch to the remote with the long name:

```bash
git push -u origin <local-name>:<category>/wolf/<ticket-key>-<kebab-summary>
```

## 5. Pull Request

Create a PR on Bitbucket targeting the integration branch (check the project's CLAUDE.md for which branch — usually `main`).

* **Title:** `<ticket-key>: <summary>`
* **Description:** Summary bullets, test plan, link to Jira ticket

Use `bb_post` to `/repositories/{workspace}/{repo}/pullrequests`.

Workspace and repo slug: infer from `git remote get-url origin`.

## 6. Rename Local Branch

Now that the PR exists, rename the local branch to signal it's in PR state:

```bash
git branch -m <local-name> pr/<local-name>
```

The remote tracking is unaffected — `pr/<local-name>` still tracks the same remote branch. Update the completion table accordingly.

## 7. Ticket Update

* Transition to PR status (transition ID `2`) via `jira_transition_issue`.
* Add a comment with the PR link and branch name via `jira_add_comment` (parameter is `body`, not `comment`).

## Completion

Summarize in a table:

| Step | Result |
|---|---|
| Ticket | SE-XXXX (link) — created / existing |
| Local branch | `pr/name` (renamed from `name`) |
| Remote branch | `full/remote/name` |
| Commit | `hash` |
| PR | #N (link) → target branch |
| Ticket status | PR |

If anything failed or was skipped, note it clearly.
