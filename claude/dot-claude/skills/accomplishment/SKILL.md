---
name: accomplishment
description: Log a notable accomplishment
argument-hint: "[description]"
allowed-tools: Read, Write, Edit, AskUserQuestion
---

# Log Notable Accomplishment

Record a significant accomplishment to the yearly accomplishments file. Argument: `$ARGUMENTS` (description, optional).

## File Location

`~/Vaults/Notes/0-log/YYYY/notable-accomplishments.md` where YYYY is the current year.

Create the year directory and file if they don't exist. If creating the file, use this template:

```markdown
---
tags:
  - topic/career
---

Notable accomplishments and significant work, logged as they happen. Each entry tagged with a category for year-end synthesis.

Categories: `[project]` · `[investigation]` · `[tool]` · `[facility]` · `[deadline]` · `[milestone]` · `[open-source]`

Add new categories as needed. Link freely to Jira tickets, Confluence pages, Obsidian notes, repos, etc.

Pattern: `[category]` `(client)` name — what you did. Why it matters.
```

## Gather Information

**Description**: Use `$ARGUMENTS` if provided, otherwise ask what was accomplished.

**Ask the user for** (skip any that are already clear from the description or conversation context):

* **Category**: One of the categories listed in the file. If the user's work doesn't fit, suggest adding a new category.
* **Client**: Who was this work for? Open-ended string, same as worklog attribution (e.g., DMP, Personal, MUG, RuntimeArguments, Family). Use dual attribution with slash if applicable (e.g., Personal/DMP).
* **Why it matters**: One sentence on the significance or impact. This is the most important part — facts are recoverable later, but context about *why something mattered* fades fast.
* **Links**: Any relevant Jira tickets, Confluence pages, Bitbucket repos, Obsidian notes. Optional but encouraged.

## Format

Append a bullet to the end of the file:

```
* `[category]` `(client)` Name/ticket — what was done. Why it matters.
```

* Keep it to one bullet (can be long — no hard-wrapping).
* Link to tickets, Confluence pages, repos inline using Markdown links.
* Use Obsidian wiki links for vault-internal references.
* The entry should stand alone — someone reading it months later should understand what happened and why it was significant without chasing links.

## Confirm

Show the bullet you're about to append and ask for approval before writing.
