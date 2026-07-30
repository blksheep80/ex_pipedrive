# ExPipedrive handoff

Status as of 2026-07-30. Use this when starting a new agent session in this repo.

## Current state

- Setup merged via [#31](https://github.com/blksheep80/ex_pipedrive/pull/31): README, `HANDOFF.md`, beads (`expd-`), devenv, agent guidance.
- **Rebrand complete** ([#1](https://github.com/blksheep80/ex_pipedrive/issues/1)): `:ex_pipedrive`, `ExPipedrive.*`, upstream attribution preserved.
- **Audit complete** ([#2](https://github.com/blksheep80/ex_pipedrive/issues/2)): keep/adapt/deprecate decisions in [AUDIT.md](AUDIT.md).
- **OTP coupling removed** ([#14](https://github.com/blksheep80/ex_pipedrive/issues/14)): no Application `mod`; webhooks use `on_event/1` callback.
- **Core deps slimmed** ([#27](https://github.com/blksheep80/ex_pipedrive/issues/27)): Timex removed; Plug is optional (webhooks only); no Phoenix/Oban in core.
- **v2 client foundation** ([#3](https://github.com/blksheep80/ex_pipedrive/issues/3), [#37](https://github.com/blksheep80/ex_pipedrive/pull/37)): `ExPipedrive.Client` owns base URL/`api_domain`; `ExPipedrive.Request` owns versioned paths (default `/api/v2`, explicit `:v1` fallback). Inherited resources still call v1 via `api_version: :v1` until #8/#9.
- **Header API token auth** ([#4](https://github.com/blksheep80/ex_pipedrive/issues/4), [#38](https://github.com/blksheep80/ex_pipedrive/pull/38)): default `x-api-token` header; legacy `auth: :query` isolated for transitional v1 only.
- **Structured errors** ([#5](https://github.com/blksheep80/ex_pipedrive/issues/5), [#39](https://github.com/blksheep80/ex_pipedrive/pull/39)): `ExPipedrive.Error` + `ExPipedrive.Response` normalize API vs transport failures.
- **Entity structs (Deal/Person)** ([#11](https://github.com/blksheep80/ex_pipedrive/issues/11)): v2-aware decoding — flat IDs, `custom_fields`, RFC3339 timestamps; v1 nested IDs still work; `original_object` retained.
- Branch `feat/v2-entity-structs` (bead `expd-1kk`) — not yet on `main`.

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

**gh CLI:** this clone must default to the fork, not upstream:

```bash
gh repo set-default origin
gh repo set-default --view   # expect blksheep80/ex_pipedrive
```

Without that, `gh pr create` can open PRs against `tmecklem/line_drive`.

## Local tooling

- **Beads** (`bd`, prefix `expd-`): execution-of-record for work in flight. Cursor rule at `.cursor/rules/beads.mdc`. Fresh clone: `bd bootstrap`.
- **GitHub issues**: product backlog / roadmap (acceptance criteria, milestones).
- **Cursor skills**: `.cursor/skills/ex-pipedrive-session`, `.cursor/skills/ex-pipedrive-pr` (plus always-on `.cursor/rules/ex-pipedrive.mdc`).
- **devenv** (optional, NixOS-friendly): `devenv.nix` pins Elixir 1.17 / OTP 27 + `dolt` for beads. `direnv allow` or `devenv shell`.
- **asdf / mise**: `.tool-versions` remains the non-Nix source of truth for Elixir/OTP.

## Issue backlog

Full tracker: https://github.com/blksheep80/ex_pipedrive/issues

**Start here (v0.1 foundation):**

1. ~~#1 Rebrand LineDrive → ExPipedrive~~ (done)
2. ~~#2 Audit inherited keep/drop decisions~~ (done — see [AUDIT.md](AUDIT.md))
3. ~~#14 Remove silent OTP Application/Registry coupling~~ (done)
4. ~~#27 Slim core dependencies~~ (done — Timex gone; Plug optional)
5. ~~#3 v2-first client foundation~~ (done)
6. ~~#4 Header-based API token auth (`x-api-token`)~~ (done)
7. ~~#5 Structured `ExPipedrive.Error`~~ (done)
8. ~~#11 Entity structs for v2 shapes~~ (done on `feat/v2-entity-structs` — Deal/Person)
9. #12 Rebuild fake-server fixtures for v2
10. #7 Cursor pagination + Stream
11. #8 Deals v2 / #9 Persons v2 / #10 MVP docs+tests

**Upstream carryovers:** no open upstream *issues* at fork time. Open PRs tracked as decisions: #24 (PR #22 search options), #25 (PR #26 weighted pipeline history).

## Suggested first agent prompt

```text
Open HANDOFF.md and GitHub issue #1. Rebrand the inherited LineDrive codebase to ExPipedrive (package, OTP app, modules, docs) with upstream attribution. Do not start API v2 work until #1 and #2 are done or explicitly scoped in.
```

## How to resume

1. Read this file (and the `ex-pipedrive-session` skill if present).
2. `bd ready` for in-flight execution items.
3. Prefer GitHub issues for the broader backlog; create/claim a bead when starting concrete work.
4. Prefer this file + GitHub issues + beads over chat transcript memory.
