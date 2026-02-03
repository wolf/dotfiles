---
name: thought
description: Capture a daily thought
disable-model-invocation: true
argument-hint: "[thought text]"
allowed-tools: Read, Write, Edit
---

# Capture Daily Thought

Record an informal thought to the daily thoughts file. Argument: `$ARGUMENTS` (the thought to capture).

## Location

Append to: `~/Vaults/Notes/0-inbox/daily-thoughts/YYYY/MM/YYYY-MM-DD.md`

Create year and month directories as needed.

## Content

Use `$ARGUMENTS` as the thought content.

**Important:** Preserve the user's words exactly. Do not:
- Edit or reformat the text
- Add structure or headings
- Correct grammar or spelling
- Summarize or paraphrase

These are informal captures meant to preserve the raw thought.

## Format

Simply append the thought text to the file, separated by a blank line from any previous content:

```
Previous thought here...

New thought goes here exactly as provided.
```

If the file doesn't exist, create it with just the thought text.
