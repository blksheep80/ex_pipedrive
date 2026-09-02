# Project Instructions for AI Agents

ExPipedrive — Elixir Pipedrive API client. See [HANDOFF.md](HANDOFF.md) and [AGENTS.md](AGENTS.md).

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

## Build & Test

```bash
mix deps.get
mix test
mix format --check-formatted
mix credo --strict
mix dialyzer
```

## Architecture Overview

Fork of LineDrive evolving to a v2-first client. Core stays lean (Tesla HTTP); OAuth TokenStore is pluggable; optional packages later for webhooks/Oban/Phoenix.
