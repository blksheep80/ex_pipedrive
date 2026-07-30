# ExPipedrive handoff

Status as of 2026-07-30. Use this when starting a new agent session in this repo.

## Locked decisions

| Item | Decision |
|---|---|
| Hex / GitHub / OTP app | `ex_pipedrive` |
| Modules | `ExPipedrive.*` |
| Strategy | Fork of [tmecklem/line_drive](https://github.com/tmecklem/line_drive), evolve v2-first (do not rewrite from scratch) |
| Auth | API token **and** OAuth in core; OAuth TokenStore is pluggable (no Ecto in core) |
| HTTP | Tesla (keep unless strong reason to switch) |
| Core vs optional | Keep core lean; later `ex_pipedrive_web`, `ex_pipedrive_oban`, optional Phoenix OAuth helpers |
| MVP proof flows | (1) stream open deals via cursor pagination (2) create person + deal |

## Remotes

- `origin` → `blksheep80/ex_pipedrive`
- `upstream` → `tmecklem/line_drive`

## Local tooling

- **Beads** (`bd`, prefix `expd-`): execution-of-record alongside GitHub issues. Cursor rule at `.cursor/rules/beads.mdc`. Fresh clone: `bd bootstrap`.
- **devenv** (optional, NixOS-friendly): `devenv.nix` pins Elixir 1.17 / OTP 27 + `dolt` for beads. `direnv allow` or `devenv shell`.
- **asdf / mise**: `.tool-versions` remains the non-Nix source of truth for Elixir/OTP.

## Issue backlog

Full tracker: https://github.com/blksheep80/ex_pipedrive/issues

**Start here (v0.1 foundation):**

1. #1 Rebrand LineDrive → ExPipedrive
2. #2 Audit inherited keep/drop decisions
3. #14 Remove silent OTP Application/Registry coupling
4. #27 Slim core dependencies
5. #3 v2-first client foundation
6. #4 Header-based API token auth (`x-api-token`)
7. #5 Structured `ExPipedrive.Error`
8. #11 Entity structs for v2 shapes
9. #12 Rebuild fake-server fixtures for v2
10. #7 Cursor pagination + Stream
11. #8 Deals v2 / #9 Persons v2 / #10 MVP docs+tests

**Upstream carryovers:** no open upstream *issues* at fork time. Open PRs tracked as decisions: #24 (PR #22 search options), #25 (PR #26 weighted pipeline history).

## Suggested first agent prompt

```text
Open HANDOFF.md and GitHub issue #1. Rebrand the inherited LineDrive codebase to ExPipedrive (package, OTP app, modules, docs) with upstream attribution. Do not start API v2 work until #1 and #2 are done or explicitly scoped in.
```

## Prior chat

Planning conversation lived under the nixos-configs workspace. Prefer this file + GitHub issues as source of truth over chat transcript memory.
