# Agent Instructions

This project is **ExPipedrive**, an Elixir Pipedrive API client (fork of LineDrive, v2-first).

Canonical context: [HANDOFF.md](HANDOFF.md) and GitHub issues on `blksheep80/ex_pipedrive`.
Day-to-day execution tracking: **bd (beads)** with prefix `expd-`.

Optional add-ons are **separate repos** with their own trackers. Do not file
`ex_pipedrive_web` / `_oban` / `_phoenix` work here:

| Package | GitHub | Beads |
|---|---|---|
| `ex_pipedrive_web` | `blksheep80/ex_pipedrive_web` | `expdw-` |
| `ex_pipedrive_oban` | `blksheep80/ex_pipedrive_oban` | `expdo-` |
| `ex_pipedrive_phoenix` | `blksheep80/ex_pipedrive_phoenix` | `expdp-` |

Project skills (read when relevant):

- `.cursor/skills/ex-pipedrive-session/SKILL.md` — session resume / sequencing
- `.cursor/skills/ex-pipedrive-pr/SKILL.md` — fork-safe `gh` / PRs
- `.cursor/skills/improve-test-coverage/SKILL.md` — coverage quick-wins (75% CI floor)
- `.cursor/skills/hunt-dead-code/SKILL.md` — transitive dead-code audit

## Cloud agents

Repo-managed environment: [`.cursor/environment.json`](.cursor/environment.json) (Elixir 1.17 / OTP 27, multi-repo siblings).

Cursor Automations (import via `/automate`): [`.cursor/automations/`](.cursor/automations/)

## Build & Test

```bash
mix deps.get
mix test
mix coveralls
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
