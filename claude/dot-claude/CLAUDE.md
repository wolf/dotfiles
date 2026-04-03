# Task Tracking

When planning multiple steps (3+), record them in a physical file rather than relying solely on in-context tracking. Place the file in the most specific location in the current project where the tasks apply. Name the file `TODO.md` (git-tracked) or `TODO.local-only.md` (git-ignored). Never use `*.local.md` — always use `*.local-only.md` for ignored files. When creating the file, ask whether it should be git-tracked or ignored. Suggest creating this file as soon as it's needed. Keep it up-to-date immediately as tasks are completed, added, or decided against.

# Persisting Preferences

When I suggest a specific behavior that could reasonably be saved in settings or a CLAUDE.md file, ask whether this should be a permanent change. If so, help me decide the appropriate location: global settings, project settings, global CLAUDE.md, or project-specific instructions.

# Session Startup

I always start Claude Code from the project directory I intend to work in. At session start:

1. Read any `CLAUDE.md` and `CLAUDE.local.md` files, plus any documents they reference
2. Get a quick sense of the file structure (a simple listing)
3. Defer deeper investigation (reading many files, understanding architecture) until we actually start working on a problem
4. When starting a brand new task, strongly suggest we enter "planning mode"

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

# Multi-Project Work

Each project gets its own terminal tab/window and its own Claude Code session. Never edit files in a different project from the current session — the wrong venv, env vars, credentials, and TODO context will be active.

* **Reading** files in other projects is fine (read-only is safe for investigation).
* **Writing** changes to another project requires a handoff: add the needed work to `inbox.local-only.md` in the target project's root directory (create it if it doesn't exist). Then switch to that project's tab/session to actually do the work.
* `inbox.local-only.md` is gitignored. It accumulates incoming items from other projects. Delete entries once completed.
* **If I ask you to `cd` to another project or edit files there, refuse.** Remind me of this rule and offer to write the item to that project's `inbox.local-only.md` instead.

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

# Git

- Use `git switch` to change branches and `git switch -c` to create branches. Do not use `git checkout` or `git branch` for these operations.
- When creating a branch that isn't explicitly local-only, immediately set its upstream to the correct remote branch (e.g., `git push -u origin branch-name` or `git branch --set-upstream-to=origin/main`), so it tracks correctly regardless of what branch was checked out at creation time.
- Always use annotated tags (`git tag -a`), never lightweight tags. Annotated tags are durable Git objects with metadata; lightweight tags are just refs.
- Version tags (used by hatch-vcs, setuptools-scm, etc.) are **durable** — once pushed, never delete or move them. If a tag was placed on the wrong commit, create a new version tag instead.

<!-- TODO: Once git-workflow-utils tooling is ready, use its branch/worktree
     naming conventions and CLI tools instead of raw git commands for creating
     branches and worktrees. -->

# Commit Messages

Use imperative mood: "Add feature" not "Added feature". Explain the "why" in the commit body for non-trivial changes.

# Markdown Style

Use `*` (asterisks) for unordered list bullets, not `-` (dashes).

Do not hard-wrap paragraphs. Write each paragraph as a single line and let the editor handle soft-wrapping.

# Communication

Show a plan before major refactoring. Be proactive about suggesting improvements. When I offer an alternative approach, treat it as a discussion, not a directive—weigh pros and cons together.

When producing shareable text (changelogs, summaries, messages), proactively offer to pipe the Markdown into `pbcopy`.

When presenting choices about edits or changes, default to the granular option (e.g., approve each edit individually) rather than bulk actions.
