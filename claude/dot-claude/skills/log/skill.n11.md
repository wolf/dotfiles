---
name: log
description: Log current session work to a drop file for worklog ingestion
argument-hint: "[description]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Log Work (n11 — drop file)

Log work from this session to a drop file for later ingestion into the
worklog. Argument: `$ARGUMENTS` (task description, optional).

The worklog vault is not accessible from this machine. This skill writes a
structured drop file that can be ingested on a machine with vault access
using `/ingest-n11`.

## Gather Information

**Description**: Use `$ARGUMENTS` if provided, otherwise summarize what was
accomplished in this session based on conversation context.

**Confirm with the user:**
* **Title**: Short description of the work. If ticket-related, prefix with
  the ticket ID (e.g., "SE-2856: Implement connection pooling").
* **Duration**: How long did this task take? Use short form: `3h`, `30m`,
  `1.5h`, `~2h`.
* **Tickets**: Any Jira ticket IDs? (Optional.)
* **Description**: Brief prose summary of what was done. Keep it to 2-3
  sentences. (Optional.)

Client is always `DMP` — don't ask.

## Write Drop File

1. Run `mkdir -p ~/worklog-drop` (idempotent).
2. Generate a filename: `YYYY-MM-DD-HHMMSS.yaml` using
   `date +%Y-%m-%d-%H%M%S`.
3. Write the YAML file to `~/worklog-drop/{filename}`:

```yaml
title: "The entry title"
duration: "1.5h"
client: DMP
tickets:
  - SE-2856
description: |
  Brief description of the work done.
```

Fields:
* `title`: required
* `duration`: required, short form only (`3h`, `30m`, `1.5h`, `~2h`)
* `client`: always `DMP`
* `tickets`: list of ticket IDs, or empty list `[]`
* `description`: optional prose, use YAML literal block scalar (`|`).
  Omit the field entirely if there's nothing worth noting.

4. Confirm: "Drop file written: `~/worklog-drop/{filename}`. Ingest on the
   work laptop with `/ingest-n11`."
