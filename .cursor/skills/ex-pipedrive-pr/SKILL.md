---
name: ex-pipedrive-pr
description: >-
  Create pull requests and use the GitHub CLI safely for the ExPipedrive fork.
  Use when opening PRs, using gh, pushing branches, or anytime remotes
  origin/upstream matter — prevents PRs against tmecklem/line_drive.
---

# ExPipedrive GitHub / PR workflow

## Remotes

- `origin` → `blksheep80/ex_pipedrive` (**default for all gh work**)
- `upstream` → `tmecklem/line_drive` (read/compare only unless asked)

## Before any `gh` write

```bash
gh repo set-default --view
# must be: blksheep80/ex_pipedrive
# else:
gh repo set-default origin
```

Prefer explicit `--repo blksheep80/ex_pipedrive` on `gh pr create` / `gh issue` when unsure.

## PR defaults

- Base branch: `main`
- Push with `git push -u origin HEAD`
- Use draft when the human asks for draft or the change is exploratory
- Do **not** push or open PRs unless the human asks (except when they explicitly request the PR action)

## Tiny docs-only fixes

Solo-repo doc/handoff tweaks may land as a direct commit on `main` when the human prefers skipping branch+PR ceremony. Feature/code work still uses a branch + PR.

## Beads with PRs

When a bead drove the work:

1. Close the bead with a reason (include commit/PR when useful).
2. Export/commit tracked `.beads/` changes with the same branch/PR (or follow-up commit on main for tiny docs).
