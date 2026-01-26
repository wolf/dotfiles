# dotfiles

This project is arranged to be installed and uninstalled by `dotx`.

## Branching Strategy

The `main` branch is public and serves as the canonical version pushed to the remote repository.

On any given machine, there may also be a branch named `local-only`. This branch:

- Is never pushed to the remote
- Is unique to that machine
- Contains machine-specific customizations

Git is configured to reduce the chance of accidentally pushing `local-only`.

## Workflow

Because this repo is intended to be `dotx`'s "source of truth", it will almost always be checked out to `local-only` on any active machine.

**Pulling updates from other machines:**

Updates pushed to `main` from other machines can be pulled and cherry-picked to `local-only`. The `sync-main.py` script simplifies this process.

**Sharing new features:**

New features created on this machine typically start as commits on `local-only`. Once they've proved themselves, they are cherry-picked to `main` and pushed to the canonical repo.

**Push safety:** Git is configured with `push.default = nothing` to prevent accidentally pushing `local-only`. Always use `git push origin main` explicitly. After any work in this repo, ensure `local-only` is checked out.
