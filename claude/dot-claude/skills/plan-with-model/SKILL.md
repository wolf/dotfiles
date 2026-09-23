---
name: plan-with-model
description: Explicit, deliberate way to choose which model plans a task. Enters plan mode immediately with whatever model is active, then hands off to a different one only once already inside it — never before, since the read-only restriction must be in force before any switch. The same gate already fires automatically before any EnterPlanMode call (see CLAUDE.md's "Planning Mode" section) — this command exists for discoverability, not because the automatic gate is missing.
argument-hint: "[model]"
allowed-tools: AskUserQuestion, EnterPlanMode
---

# Plan With Model

Choose which model plans the upcoming task, then enter plan mode. Argument: `$ARGUMENTS` (a model name, optional).

## 1. Resolve the desired model

**If `$ARGUMENTS` names a model** (e.g., `/plan-with-model opus`, `/plan-with-model fable`): use it directly, skipping the question below.

**Otherwise**, ask which model to plan in. Offer the models currently available (check the system context for the current roster — it changes over time, so don't rely on a hardcoded list) plus a "keep current" option.

## 2. Enter plan mode immediately

Call `EnterPlanMode` now, before anything else, using whatever model is currently active — regardless of whether a switch is coming.

Plan mode's read-only restriction must be in force before any model switch, never after: switching first would leave a window where the freshly-active model runs with full write permissions before anything confines it. That's the whole reason this skill enters plan mode before checking the model, rather than after.

## 3. Compare against the active model

The active model is stated in this session's system context (e.g., "You are powered by the model named ..."). If the desired model **is** the active one, or "keep current" was chosen, there's nothing more to do — proceed with the actual planning work.

## 4. Hand off the switch

Otherwise, stop here. There's no tool that can change the session's active model. Tell the user to run `/model <name>` themselves, then wait for them to confirm the switch is done. Do not do any exploration or design work until they do — only then proceed with the actual planning work, now already safely inside plan mode.
