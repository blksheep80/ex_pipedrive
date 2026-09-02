---
name: ex-pipedrive-session
description: >-
  Resume ExPipedrive work correctly: read HANDOFF, check beads, respect
  foundation issue order, and avoid jumping into API v2 before rebrand/audit.
  Use at session start, when picking up the repo, or when the user asks what
  to work on next.
---

# ExPipedrive session resume

## Do first

1. Read `HANDOFF.md` (locked decisions + current state + next issues).
2. Run `bd ready` (and `bd list --status=in_progress` if useful).
3. Confirm `gh repo set-default --view` → `blksheep80/ex_pipedrive`. If not:

```bash
gh repo set-default origin
```

4. Prefer GitHub issues for roadmap; create/claim a **bead** when starting concrete work.

## Sequencing

Do **not** start API v2 work until GitHub **#1** (rebrand) and **#2** (audit) are done or the human explicitly scopes them in.

v0.1 foundation order lives in `HANDOFF.md`.

## Quality gate (when code changes)

```bash
mix test
mix format --check-formatted
mix credo --strict
mix dialyzer
```

## Tracking split

| Layer | Use for |
|---|---|
| `HANDOFF.md` | Where we are / locked decisions |
| GitHub issues | Product backlog, acceptance criteria |
| beads (`expd-`) | Work in flight; close with reason |

Do not use TodoWrite / markdown TODO lists for task tracking in this repo.
