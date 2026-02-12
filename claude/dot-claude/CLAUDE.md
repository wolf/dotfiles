# Task Tracking

When planning multiple steps (3+), record them in a physical file rather than relying solely on in-context tracking. Place the file in the most specific location in the current project where the tasks apply. Name the file `TODO.md` or `TODO.local.md`. When creating the file, ask whether it should be git-tracked or ignored. Suggest creating this file as soon as it's needed. Keep it up-to-date immediately as tasks are completed, added, or decided against.

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

Use `/new-task` to start, `/resume-task` to continue, `/wrapup-task` to close out. See also: `/log-this`, `/log-other`, `/thought`, `/worktree`.

# Philosophy

Solve the right problem—the one you actually have, not the one you want to have—with the simplest reasonable answer.

Use names, types, calling patterns, and documentation to give the caller correct expectations. The code's job is to satisfy those expectations, never surprising the user.

Within that framework, code must be correct, reliable, performant, and well-tested. Good documentation, Pythonic code, good names, and type annotations all serve this effort.

No one starts with the simplest answer. It always starts complicated. Programming is like sculpting: chip away at what isn't needed until you arrive at the simple, obvious, fast version.

# Language-Specific Guidelines

Language rules live in `languages/` and should be read when writing code in that language. Available: `languages/python.md`.

# Bash Commands

When running commands that target a specific directory (like git commands), `cd` to that directory first rather than using flags like `git -C <path>`. This keeps commands simple and matches the allowed command patterns in settings.

# Git

- Use `git switch` to change branches and `git switch -c` to create branches. Do not use `git checkout` or `git branch` for these operations.
- When creating a branch that isn't explicitly local-only, immediately set its upstream to the correct remote branch (e.g., `git push -u origin branch-name` or `git branch --set-upstream-to=origin/main`), so it tracks correctly regardless of what branch was checked out at creation time.

<!-- TODO: Once git-workflow-utils tooling is ready, use its branch/worktree
     naming conventions and CLI tools instead of raw git commands for creating
     branches and worktrees. -->

# Commit Messages

Use imperative mood: "Add feature" not "Added feature". Explain the "why" in the commit body for non-trivial changes.

# Communication

Show a plan before major refactoring. Be proactive about suggesting improvements. When I offer an alternative approach, treat it as a discussion, not a directive—weigh pros and cons together.

When producing shareable text (changelogs, summaries, messages), proactively offer to pipe the Markdown into `pbcopy`.

When presenting choices about edits or changes, default to the granular option (e.g., approve each edit individually) rather than bulk actions.
