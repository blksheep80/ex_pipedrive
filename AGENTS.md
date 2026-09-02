# Agent Instructions

This project is **ExPipedrive**, an Elixir Pipedrive API client (fork of LineDrive, v2-first).

Canonical context: [HANDOFF.md](HANDOFF.md) and GitHub issues on `blksheep80/ex_pipedrive`.
Day-to-day execution tracking: **bd (beads)** with prefix `expd-`.

Project skills (read when relevant):

- `.cursor/skills/ex-pipedrive-session/SKILL.md` — session resume / sequencing
- `.cursor/skills/ex-pipedrive-pr/SKILL.md` — fork-safe `gh` / PRs

## Build & Test

```bash
mix deps.get
mix test
mix format --check-formatted
mix credo --strict
mix dialyzer
```

Optional Nix shell (NixOS / devenv):

```bash
direnv allow   # or: devenv shell
```

## Conventions

- Do not start API v2 work until GitHub #1 (rebrand) and #2 (audit) are done or explicitly scoped in.
- Prefer small PRs aligned to the v0.1 foundation order in HANDOFF.md.
- Do not commit secrets, `.env`, or Firecrawl scratch (`.firecrawl/`).
- Commit tracked `.beads/` state when `bd` creates/updates/closes issues as part of the work.
- Only `git push` / publish when the human explicitly asks.

## Issue Tracking

This project uses **bd (beads)** for issue tracking.
Run `bd prime` for workflow context.

**Quick reference:**
- `bd ready` - Find unblocked work
- `bd create "Title" --type task --priority 2` - Create issue
- `bd close <id>` - Complete work
- `bd dolt push` - Push beads DB (when asked to sync remotes)

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:ca08a54f -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files
<!-- END BEADS INTEGRATION -->
