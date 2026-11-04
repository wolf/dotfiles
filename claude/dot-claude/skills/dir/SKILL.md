---
name: dir
description: Wolf's "you're in the wrong directory" signal. Return the shell to the directory the session started in, then stop drifting. Invoke on /dir, or when Wolf says the working directory is wrong.
allowed-tools: Bash
---

# Dir

Wolf is telling you the shell's working directory is wrong. The cause is almost always one of your own earlier Bash calls: a bare `cd` persists between commands and silently changes the base of every later command (the environment note "Primary working directory ... (was ...)" shows each drift).

## Procedure

1. Find the **start directory**: the primary working directory the session began in (Wolf always starts Claude Code from the project he means to work in). It is the first "Primary working directory" the environment reported, or the `was` value of the earliest drift note. If in doubt, it is the directory holding the `CLAUDE.md` loaded at session start.
2. Run `cd <start directory> && pwd` and confirm the output matches.
3. Say in one line where you are now and what moved you (for example "back in `~/Vaults/Notes`; my last command `cd`'d into a skill's scripts directory").
4. Check whether any file was written, or any command run, in the wrong directory since the drift. Report it only if something was, and fix it.

## From now on

* One-off work in another directory runs in a subshell, `(cd /other/path && ...)`, so the session's directory never changes.
* Any command that depends on the working directory starts with `cd <intended directory> && ...` instead of assuming the previous command left it correct.
* Never `cd` into a directory in a bare command, even a read-only one.

Keep the reply short: Wolf is often typing one-handed.
