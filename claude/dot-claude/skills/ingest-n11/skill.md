---
name: ingest-n11
description: Pull and log work entries from n11
argument-hint: ""
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Ingest n11 Drop Files

Pull pending worklog drop files from n11 and create worklog entries.

## Conventions

Read `~/Vaults/Notes/0-log/worklog/CLAUDE.md` for the canonical worklog
format — frontmatter schema, entry format, duration short forms, and client
attribution rules.

## Procedure

1. **Pull drop files from n11**:
   ```
   mkdir -p /tmp/worklog-drop
   scp n11:~/worklog-drop/*.yaml /tmp/worklog-drop/
   ```
   If no files are found, report "No pending entries on n11" and stop.

2. **Read each drop file** in `/tmp/worklog-drop/`. Each contains:
   ```yaml
   title: "Entry title"
   duration: "1.5h"
   client: DMP
   tickets: [SE-2856]
   description: |
     Brief description.
   ```

3. **Show the user** a summary of all entries to be ingested. Ask for
   confirmation before writing.

4. **For each entry**, append to today's worklog file at
   `~/Vaults/Notes/0-log/worklog/YYYY/MM/YYYY-MM-DD.md`:
   - Create the file and directories if needed
   - Add the entry in standard worklog format (see CLAUDE.md)
   - Update YAML frontmatter to reflect all entries

5. **Clean up**:
   - Delete the processed files from n11:
     `ssh n11 'rm ~/worklog-drop/*.yaml'`
   - Delete local temp files:
     `rm /tmp/worklog-drop/*.yaml`

6. **Confirm**: List the entries that were created.

## Notes

- All entries are DMP by default (work on n11 is always DMP).
- If a drop file has tickets, include them in the worklog entry.
- The description field becomes the entry's body text.
- Entries always go into **today's** worklog file, regardless of when the
  drop file was created. If that's wrong (e.g., work from yesterday),
  the user will say so during the confirmation step.
- The `n11` hostname must be resolvable via SSH config on the work laptop.
