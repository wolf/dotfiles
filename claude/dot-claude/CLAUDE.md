# Task Tracking

When planning multiple steps (3+), record them in a physical file rather than relying solely on in-context tracking. Place the file in the most specific location in the current project where the tasks apply. Name the file `TODO.md` (git-tracked) or `TODO.local-only.md` (git-ignored). Never use `*.local.md` — always use `*.local-only.md` for ignored files. When creating the file, ask whether it should be git-tracked or ignored. Suggest creating this file as soon as it's needed. Keep it up-to-date immediately as tasks are completed, added, or decided against.

# Referencing Local-Only Files

Never reference a gitignored or otherwise untracked file (`*.local-only.md`, `TODO.local-only.md`, scratch notes, etc.) from a document that is itself committed/shared (README, ARCHITECTURE, ROADMAP, a doc site, a PR description). The reference will be dead for every reader except the one machine that has the file — it was never pushed, and never will be. Point a shared document at another shared, tracked artifact instead (a ticket, a CHANGELOG entry, a committed doc), even if that means summarizing the local-only content rather than linking to it.

# Persisting Preferences

When I suggest a specific behavior that could reasonably be saved in settings or a CLAUDE.md file, ask whether this should be a permanent change. If so, help me decide the appropriate location: global settings, project settings, global CLAUDE.md, or project-specific instructions.

# Session Startup

I always start Claude Code from the project directory I intend to work in. At session start:

1. Read any `CLAUDE.md` and `CLAUDE.local.md` files, plus any documents they reference
2. Get a quick sense of the file structure (a simple listing)
3. Defer deeper investigation (reading many files, understanding architecture) until we actually start working on a problem
4. When starting a brand new task, strongly suggest we enter "planning mode"

# Planning Mode

For a new planning task, ask which model I want to plan in before doing anything else — don't assume the session's current default (e.g., an "opusplan" preset's Opus) is what I want this time; I sometimes want a different model (e.g. Fable) for a specific task. Offer the available models plus "keep current." Skip this gate if we're already mid-planning-conversation, or if I've already told you which model to use for this task.

**Call `EnterPlanMode` immediately after that question, before anything else** — regardless of whether a switch is needed, using whatever model is currently active. Plan mode's read-only restriction must be in force before any model switch, never after: switching outside plan mode leaves a window where the freshly-active model runs with full write permissions before anything confines it, which is a bigger risk than the switch itself. Only once safely inside plan mode do you check whether the model I picked differs from the one that's now active. If it does, stop there: tell me to run `/model <name>` myself — there's no tool that can switch the session's model for me — and wait for me to confirm the switch is done before doing any actual exploration or design work.

`/plan-with-model` exists as an explicit, deliberate way to invoke this same gate — check for it — but the behavior above applies automatically either way; the command is just an alias for discoverability, not different logic.

# Workflow

Sustainable productivity requires both reducing friction and maintaining discipline.

## Automation

Friction kills productivity. Repetitive manual tasks are candidates for automation—but only when the math works out: will I do this often enough that the time saved exceeds the time to automate?

When building tools or scripts I'll use alone later, ask whether this is something I'll do often.

## Modern Tools

I prefer modern tools when they offer clear wins—I'm always happy to learn. Examples: `rg` over `grep`, `fd` over `find`, `eza` over `ls`, `tmux` over `screen`, `pixi` over `conda`, `uv` over `pip`.

Be proactive: when you know of a better tool for what we're doing, suggest it. Also help me investigate and evaluate tools I discover.

## Task Discipline

I tend to keep rolling from task to task without pausing to commit and document. Help me maintain boundaries.

Prompt when we might be done with a standalone piece of work. Completed units should be committed by themselves before moving on.

Every unit of work needs a Jira ticket. Strongly discourage working without one.

## Incremental Delivery

Big plans must be broken into steps where each completed step is a valid point in time:

* The program runs correctly
* All tests pass
* Documentation matches the behavior and interface of the code
* The plan file (TODO.md or equivalent) is updated to reflect what's done and what remains, so anyone — human or new session — can pick up from this point without prior context

**Planning and tickets:** Each step typically needs its own Jira ticket. Plans large enough to span multiple steps get an epic, and all step tickets belong to that epic.

**Audit every step:** Before a step can be committed, new code and tests must be audited against the code audit checklist (`~/develop/dmp/dmp-coding-standards/code-audit-checklist.md`). This is not a cleanup pass before delivery — it is part of every step. In particular, verify that tests test **promises**, not implementations.

**Delivery:** A completed step satisfying these conditions is pushed to main. If the step provides a helpful new state for consumers, it should be released — version bump, matching tag, and placement on the release branch.

The goal: minimize unmerged work, reduce merge conflicts, and make interruptions painless. Any completed step is a safe stopping point.

## Proactive Skill Invocation

Don't wait for slash commands. Recognize intent and act.

**Natural language → invoke immediately:**

| Pattern | Skill |
|---|---|
| "I went to bed at...", "bedtime was..." | `/sleep` |
| "I woke up at...", "got up at..." | `/wake` |
| "I started work at...", "clocked in at..." | `/start-workday` |
| "I left work at...", "done for the day" | `/end-workday` |
| "I had a meeting...", "just got out of [meeting]" | `/log-meeting` |
| "I commuted...", "drove in..." | `/commute` |
| "I spent Xh on...", describes external work | `/log` |
| Fleeting thought, reflection, observation | `/thought` |
| "what should I work on?", "what's next?" | `/triage` |
| "let's work on X", "I need to fix Y" | `/begin` |
| "something came up", "pause this" | `/interrupt` |
| "this is ready", "ship it", "PR this" | `/deliver` |
| "triage/process my voice notes", "go through my JPR recordings" | `/triage-jpr` |
| Multiple state updates in one message | Batch all relevant skills in parallel |

**Context-aware prompting — offer at transitions:**

| Transition | Prompt |
|---|---|
| Finished standalone work | "Want me to log this?" |
| Session start in a project directory | Run `/triage` |
| Tests pass, work looks complete | "Ready to deliver?" |
| Significant achievement | "Worth an accomplishment entry?" |

## Task Manager

OmniFocus is the sole task manager. Do not check or reference Things.

## Document Disposition

Every content type has one canonical home. Before creating or suggesting placement of any artifact, follow these rules. Push back if I'm about to put something in the wrong place.

| Content type | Belongs in |
|---|---|
| Text I write or cause to be written (notes, observations, worklog, saved plans, etc.) | Obsidian vault |
| Books and manuals (not audiobooks), including manuals for physical things I own | Calibre |
| Reference material, especially external PDFs and screenshots | DEVONthink |
| Live code | `~/develop` (per its existing structure) |
| Tasks | OmniFocus |
| Scheduled events and meetings | Calendar |

# Multi-Project Work

Each project gets its own terminal tab/window and its own Claude Code session. Never edit files in a different project from the current session — the wrong venv, env vars, credentials, and TODO context will be active.

* **Reading** files in other projects is fine (read-only is safe for investigation).
* **Writing** changes to another project requires a handoff. For DMP projects, write the item to `~/Vaults/Notes/2-projects/dmp/<project-name>/inbox.md` (synced via Obsidian, visible across sessions). For non-DMP projects, use `inbox.local-only.md` in the project root (create it if it doesn't exist). Then switch to that project's tab/session to actually do the work.
* DMP vault inboxes are the canonical cross-project handoff for DMP work. `inbox.local-only.md` files in develop repos are the fallback for non-DMP or non-vault contexts.
* **If I ask you to `cd` to another project or edit files there, refuse.** Remind me of this rule and offer to write the item to that project's vault inbox (or `inbox.local-only.md` for non-DMP) instead.

# Philosophy

Solve the right problem—the one you actually have, not the one you want to have—with the simplest reasonable answer.

Use names, types, calling patterns, and documentation to give the caller correct expectations. The code's job is to satisfy those expectations, never surprising the user.

Within that framework, code must be correct, reliable, performant, and well-tested. Good documentation, Pythonic code, good names, and type annotations all serve this effort.

No one starts with the simplest answer. It always starts complicated. Programming is like sculpting: chip away at what isn't needed until you arrive at the simple, obvious, fast version.

New or changed code implies new or changed documentation. Every change to functionality, architecture, models, or public interfaces must include corresponding documentation updates — whether that's comments, docstrings, README, or dedicated docs. This is not optional; always consider what documentation a change requires.

# Language-Specific Guidelines

Language rules live in `languages/` and should be read when writing code in that language. Available: `languages/python.md`.

# Bash Commands

When running commands that target a specific directory (like git commands), `cd` to that directory first rather than using flags like `git -C <path>`. This keeps commands simple and matches the allowed command patterns in settings.

The shell working directory persists between commands, so a `cd` done for a one-off task silently changes the base directory of every later command. Two rules prevent wrong-directory mistakes:

* One-off work in another directory (inspecting another repo, checking a file tree) runs in a subshell — `(cd /other/path && ...)` — so the session's working directory never changes.
* Any command that depends on the working directory establishes it explicitly (`cd <intended-dir> && ...`) instead of assuming the previous command left it correct.

Commands run under zsh, where an unquoted word starting with `=` triggers equals expansion (`=foo` → path of command `foo`). A bare `echo ===` separator therefore fails with `== not found` and kills the rest of the command chain. Quote such words (`echo "==="`) or use a separator that isn't special, like `---`.

## Shebangs

First decide what the script actually needs, then declare exactly that. Most scripts written `#!/bin/bash` out of habit are pure POSIX and never touch a bash feature.

* **Needs bash** — arrays, `[[ ]]`, `pipefail`, `PIPESTATUS`, `local`, `source` (vs `.`), process substitution `<(...)`, `+=`, `declare`/`mapfile`: write `#!/usr/bin/env bash`. Never `#!/bin/bash` — a hardcoded path silently picks whatever the system shipped, which on macOS is bash 3.2 from 2007 even when a modern bash is first on `PATH`.
* **Pure POSIX** — write `#!/bin/sh`. This is the one case where hardcoding is right: POSIX guarantees `/bin/sh` exists, and `env sh` buys nothing while reading oddly.
* **Same rule for other interpreters**: `#!/usr/bin/env python3`, not `#!/usr/bin/python3`.

The trap in the other direction is worse than an over-broad `bash`: writing `#!/bin/sh` and then *using* bashisms. It works wherever `/bin/sh` happens to be bash and breaks on Debian/Ubuntu, where it's dash. So match the shebang to what the script actually uses — check, don't assume. Over-declaring bash for a POSIX script is merely imprecise; under-declaring it is a latent portability bug.

# Git

- Use `git switch` to change branches and `git switch -c` to create branches. Do not use `git checkout` or `git branch` for these operations.
- When creating a branch that isn't explicitly local-only, immediately set its upstream to the correct remote branch (e.g., `git push -u origin branch-name` or `git branch --set-upstream-to=origin/main`), so it tracks correctly regardless of what branch was checked out at creation time.
- Always use annotated tags (`git tag -a`), never lightweight tags. Annotated tags are durable Git objects with metadata; lightweight tags are just refs.
- Version tags (used by hatch-vcs, setuptools-scm, etc.) are **durable** — once pushed, never delete or move them. If a tag was placed on the wrong commit, create a new version tag instead.

<!-- TODO: Once git-workflow-utils tooling is ready, use its branch/worktree
     naming conventions and CLI tools instead of raw git commands for creating
     branches and worktrees. -->

# Committing

When I allow you to write or edit code, I must review the changes before you create a commit — every time. After edits are done, stop and wait for explicit approval to commit. I review externally in a separate terminal using git tools, so you don't need to show diffs or summaries inline.

Explicit approval can come bundled in the original request ("make the change and commit it") or as a follow-up ("commit it"). Otherwise, do not run `git commit`, even when the work looks clearly done.

This applies to any file you write, including config, docs, and dotfiles — not just source code.

# Commit Messages

Use imperative mood: "Add feature" not "Added feature". Explain the "why" in the commit body for non-trivial changes.

# Licensing

My standard license for personal projects is MIT (Copyright Wolf). When creating a project or adding a LICENSE, default to MIT unless a more specific CLAUDE.md or the project itself says otherwise.

# Markdown Style

Use `*` (asterisks) for unordered list bullets, not `-` (dashes).

Do not hard-wrap paragraphs. Write each paragraph as a single line and let the editor handle soft-wrapping.

# Communication

Show a plan before major refactoring. Be proactive about suggesting improvements. When I offer an alternative approach, treat it as a discussion, not a directive—weigh pros and cons together.

When producing shareable text (changelogs, summaries, messages), proactively offer to pipe the Markdown into `pbcopy`.

When presenting choices about edits or changes, default to the granular option (e.g., approve each edit individually) rather than bulk actions.

When presenting choices that include code samples, always show the full samples inline in chat as normal fenced code blocks. Never use the `AskUserQuestion` preview box for code samples — it hard-truncates long content with a `✂ N lines hidden` cut line and has no scroll or expand in the TUI.
