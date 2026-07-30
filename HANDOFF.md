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
- **Entity structs (Deal/Person)** ([#11](https://github.com/blksheep80/ex_pipedrive/issues/11), [#40](https://github.com/blksheep80/ex_pipedrive/pull/40)): v2-aware decoding — flat IDs, `custom_fields`, RFC3339 timestamps; v1 nested IDs still work; `original_object` retained.
- **v2 fake fixtures** ([#12](https://github.com/blksheep80/ex_pipedrive/issues/12), [#41](https://github.com/blksheep80/ex_pipedrive/pull/41)): FakePipedriveServer serves `/api/v2/deals` + `/api/v2/persons` with cursor + error samples.
- **Cursor pagination + Stream** ([#7](https://github.com/blksheep80/ex_pipedrive/issues/7), [#42](https://github.com/blksheep80/ex_pipedrive/pull/42)): `ExPipedrive.Page` / `Cursor.stream/2`; `list_deals_page` / `stream_deals` (+ persons).
- **Deals / Persons v2 + MVP flows** ([#8](https://github.com/blksheep80/ex_pipedrive/issues/8) / [#9](https://github.com/blksheep80/ex_pipedrive/issues/9) / [#10](https://github.com/blksheep80/ex_pipedrive/issues/10), [#43](https://github.com/blksheep80/ex_pipedrive/pull/43)): v2 get/create/update/(deal)delete; map-in write attrs; README + fake-server MVP flows.
- **OAuth Token + TokenStore** ([#6](https://github.com/blksheep80/ex_pipedrive/issues/6), [#44](https://github.com/blksheep80/ex_pipedrive/pull/44)): `Oauth.Token`, `exchange_authorization_code` / `refresh` / `ensure_fresh`, pluggable `TokenStore` (+ Memory), `Client.from_token` / `from_token_store`.
- **Hex / docs / CI prep** ([#28](https://github.com/blksheep80/ex_pipedrive/issues/28), [#45](https://github.com/blksheep80/ex_pipedrive/pull/45)): version `0.1.0`, CHANGELOG, ExDoc config, CI matrix, Hex publish workflow. Cut GitHub Release `v0.1.0` (with `HEX_API_KEY`) to publish.
- **Quality tooling** ([#32](https://github.com/blksheep80/ex_pipedrive/issues/32)): `doctor` gate; TypedStruct kept; Sobelow/ExMachina skipped; Dialyzer local-only for now (AUDIT).
- On `main`, v0.1 foundation is complete. **v0.2** is underway: resource epic [#17](https://github.com/blksheep80/ex_pipedrive/issues/17) split into [#47](https://github.com/blksheep80/ex_pipedrive/issues/47)–[#52](https://github.com/blksheep80/ex_pipedrive/issues/52). Organizations [#53](https://github.com/blksheep80/ex_pipedrive/pull/53) and Activities [#54](https://github.com/blksheep80/ex_pipedrive/pull/54) merged; Pipelines v2 on `feature/pipelines-v2` (bead `expd-i76`).

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

**Start here (v0.1 foundation):** — all done (see Current state).

**v0.2 resources** (epic [#17](https://github.com/blksheep80/ex_pipedrive/issues/17)):

1. [#47](https://github.com/blksheep80/ex_pipedrive/issues/47) Organizations v2 (done — [#53](https://github.com/blksheep80/ex_pipedrive/pull/53))
2. [#48](https://github.com/blksheep80/ex_pipedrive/issues/48) Activities v2 (done — [#54](https://github.com/blksheep80/ex_pipedrive/pull/54))
3. [#49](https://github.com/blksheep80/ex_pipedrive/issues/49) Pipelines v2 (in progress — [#55](https://github.com/blksheep80/ex_pipedrive/pull/55))
4. [#50](https://github.com/blksheep80/ex_pipedrive/issues/50) Stages v2
5. [#51](https://github.com/blksheep80/ex_pipedrive/issues/51) Products v2
6. [#52](https://github.com/blksheep80/ex_pipedrive/issues/52) Search v2

Also open for v0.2: [#15](https://github.com/blksheep80/ex_pipedrive/issues/15) Raw escape hatch, [#16](https://github.com/blksheep80/ex_pipedrive/issues/16) Resource behaviour, [#13](https://github.com/blksheep80/ex_pipedrive/issues/13) rate-limit/telemetry, [#18](https://github.com/blksheep80/ex_pipedrive/issues/18) Leads/Notes v1 shim, [#19](https://github.com/blksheep80/ex_pipedrive/issues/19) ex_pipedrive_web.

**Upstream carryovers:** no open upstream *issues* at fork time. Open PRs tracked as decisions: #24 (PR #22 search options), #25 (PR #26 weighted pipeline history).

## Suggested first agent prompt

```text
Open HANDOFF.md and claim Organizations v2 (#47 / expd-ruk) or the next ready v0.2 child under #17. Prefer small PRs. Do not publish Hex unless asked.
```

## How to resume

1. Read this file (and the `ex-pipedrive-session` skill if present).
2. `bd ready` for in-flight execution items.
3. Prefer GitHub issues for the broader backlog; create/claim a bead when starting concrete work.
4. Prefer this file + GitHub issues + beads over chat transcript memory.
