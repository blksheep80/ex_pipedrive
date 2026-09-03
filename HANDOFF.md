# ExPipedrive handoff

Status as of 2026-09-02. Use this when starting a new agent session in this repo.

## Current state

- Setup merged via [#31](https://github.com/blksheep80/ex_pipedrive/pull/31): README, `HANDOFF.md`, beads (`expd-`), devenv, agent guidance.
- **Rebrand complete** ([#1](https://github.com/blksheep80/ex_pipedrive/issues/1)): `:ex_pipedrive`, `ExPipedrive.*`, upstream attribution preserved.
- **Audit complete** ([#2](https://github.com/blksheep80/ex_pipedrive/issues/2)): keep/adapt/deprecate decisions in [AUDIT.md](AUDIT.md).
- **OTP coupling removed** ([#14](https://github.com/blksheep80/ex_pipedrive/issues/14)): no Application `mod`; webhooks use `on_event/1` callback.
- **Core deps slimmed** ([#27](https://github.com/blksheep80/ex_pipedrive/issues/27)): Timex removed; Plug is not a core dep (inbound Plug is `ex_pipedrive_web`); no Phoenix/Oban in core.
- **v2 client foundation** ([#3](https://github.com/blksheep80/ex_pipedrive/issues/3), [#37](https://github.com/blksheep80/ex_pipedrive/pull/37)): `ExPipedrive.Client` owns base URL/`api_domain`; `ExPipedrive.Request` owns versioned paths (default `/api/v2`, explicit `:v1` fallback). Inherited resources still call v1 via `api_version: :v1` until #8/#9.
- **Header API token auth** ([#4](https://github.com/blksheep80/ex_pipedrive/issues/4), [#38](https://github.com/blksheep80/ex_pipedrive/pull/38)): default `x-api-token` header; legacy `auth: :query` isolated for transitional v1 only.
- **Structured errors** ([#5](https://github.com/blksheep80/ex_pipedrive/issues/5), [#39](https://github.com/blksheep80/ex_pipedrive/pull/39)): `ExPipedrive.Error` + `ExPipedrive.Response` normalize API vs transport failures.
- **Entity structs (Deal/Person)** ([#11](https://github.com/blksheep80/ex_pipedrive/issues/11), [#40](https://github.com/blksheep80/ex_pipedrive/pull/40)): v2-aware decoding — flat IDs, `custom_fields`, RFC3339 timestamps; v1 nested IDs still work; `original_object` retained.
- **v2 fake fixtures** ([#12](https://github.com/blksheep80/ex_pipedrive/issues/12), [#41](https://github.com/blksheep80/ex_pipedrive/pull/41)): FakePipedriveServer serves `/api/v2/deals` + `/api/v2/persons` with cursor + error samples.
- **Cursor pagination + Stream** ([#7](https://github.com/blksheep80/ex_pipedrive/issues/7), [#42](https://github.com/blksheep80/ex_pipedrive/pull/42)): `ExPipedrive.Page` / `Cursor.stream/2`; `list_deals_page` / `stream_deals` (+ persons).
- **Deals / Persons v2 + MVP flows** ([#8](https://github.com/blksheep80/ex_pipedrive/issues/8) / [#9](https://github.com/blksheep80/ex_pipedrive/issues/9) / [#10](https://github.com/blksheep80/ex_pipedrive/issues/10), [#43](https://github.com/blksheep80/ex_pipedrive/pull/43)): v2 get/create/update/(deal)delete; map-in write attrs; README + fake-server MVP flows.
- **OAuth Token + TokenStore** ([#6](https://github.com/blksheep80/ex_pipedrive/issues/6), [#44](https://github.com/blksheep80/ex_pipedrive/pull/44)): `Oauth.Token`, `exchange_authorization_code` / `refresh` / `ensure_fresh`, pluggable `TokenStore` (+ Memory), `Client.from_token` / `from_token_store`.
- **Hex / docs / CI prep** ([#28](https://github.com/blksheep80/ex_pipedrive/issues/28), [#45](https://github.com/blksheep80/ex_pipedrive/pull/45), [#85](https://github.com/blksheep80/ex_pipedrive/issues/85)): version `0.1.0`, CHANGELOG, ExDoc, CI matrix, Hex publish workflow; `HEX_API_KEY` secret set. First Hex publish via GitHub Release `v0.1.0`.
- **Quality tooling** ([#32](https://github.com/blksheep80/ex_pipedrive/issues/32)): `doctor` gate; TypedStruct kept; Sobelow/ExMachina skipped. **Dialyzer in CI** ([#84](https://github.com/blksheep80/ex_pipedrive/issues/84)): primary matrix cell + PLT cache. **Test coverage** ([#133](https://github.com/blksheep80/ex_pipedrive/issues/133)): ExCoveralls + Coveralls badge.
- On `main`, v0.1 foundation is complete. **v0.2** resource epic [#17](https://github.com/blksheep80/ex_pipedrive/issues/17) children [#47](https://github.com/blksheep80/ex_pipedrive/issues/47)–[#52](https://github.com/blksheep80/ex_pipedrive/issues/52) are done (Organizations–Search). Product variations remain a follow-up. Upstream search-options decision [#24](https://github.com/blksheep80/ex_pipedrive/issues/24): v2 `Search` uses explicit opts (`item_types`, `fields`, `exact_match`, …) instead of opaque keyword merge from LineDrive PR #22.
- **Raw escape hatch** ([#15](https://github.com/blksheep80/ex_pipedrive/issues/15), [#59](https://github.com/blksheep80/ex_pipedrive/pull/59)): `ExPipedrive.Raw.request/4` for unsupported v1/v2 endpoints (query/body/headers pass-through; shared auth/JSON/`Error` normalization).
- **Resource behaviour** ([#16](https://github.com/blksheep80/ex_pipedrive/issues/16), [#60](https://github.com/blksheep80/ex_pipedrive/pull/60)): `ExPipedrive.Resource` path/decode/encode + CRUD/list/stream helpers; Products/Stages adopt the pattern.
- **Rate-limit / telemetry** ([#13](https://github.com/blksheep80/ex_pipedrive/issues/13), [#61](https://github.com/blksheep80/ex_pipedrive/pull/61)): `Middleware.Retry` (429/`Retry-After`, 502–504), `Middleware.Telemetry` (`[:ex_pipedrive, :request, …]`), `RateLimit` parser, Client `:retry`/`:telemetry`/`:middleware`.
- **Leads / Notes v1 shims** ([#18](https://github.com/blksheep80/ex_pipedrive/issues/18), [#62](https://github.com/blksheep80/ex_pipedrive/pull/62)): explicit v1 routing, map writes, `get/create/list` aliases.
- **Webhook surface** ([#19](https://github.com/blksheep80/ex_pipedrive/issues/19), [#63](https://github.com/blksheep80/ex_pipedrive/pull/63)): `Webhook.Event` / `Webhook.Handler` in core; inbound Plug extracted to `ex_pipedrive_web` ([#82](https://github.com/blksheep80/ex_pipedrive/issues/82)).
- **Webhook event normalization** ([#81](https://github.com/blksheep80/ex_pipedrive/issues/81)): typed decode for org/activity/lead/note/product (+ pipeline/stage/user/…); v1 merged + v2 create/change/delete; unknown resources stay maps.
- **Webhook subscriptions** ([#23](https://github.com/blksheep80/ex_pipedrive/issues/23), [#64](https://github.com/blksheep80/ex_pipedrive/pull/64)): `ExPipedrive.Webhooks` create/list/delete (API v1 management).
- **Fields helpers** ([#22](https://github.com/blksheep80/ex_pipedrive/issues/22), [#65](https://github.com/blksheep80/ex_pipedrive/pull/65)): v2 Deal/Person/Org Fields list/stream + `ExPipedrive.Fields` key/label resolve.
- **Upstream #25**: skipped — LineDrive PR #26 is mistitled; only v1 `pipeline_id` filter (already covered by v2 `Deals.list_page/stream`).

- **Wave A CRM coverage** ([#66](https://github.com/blksheep80/ex_pipedrive/issues/66)): Users [#67](https://github.com/blksheep80/ex_pipedrive/issues/67)/[#90](https://github.com/blksheep80/ex_pipedrive/pull/90), Filters [#69](https://github.com/blksheep80/ex_pipedrive/issues/69)/[#91](https://github.com/blksheep80/ex_pipedrive/pull/91), Labels [#70](https://github.com/blksheep80/ex_pipedrive/issues/70)/[#92](https://github.com/blksheep80/ex_pipedrive/pull/92), LeadValue currency [#80](https://github.com/blksheep80/ex_pipedrive/issues/80)/[#89](https://github.com/blksheep80/ex_pipedrive/pull/89).
- **Files / attachments** ([#68](https://github.com/blksheep80/ex_pipedrive/issues/68), [#93](https://github.com/blksheep80/ex_pipedrive/pull/93)): `ExPipedrive.Files` multipart upload/download/list/get/update/delete + Google Drive remote helpers (API v1).
- **Wave B** ([#71](https://github.com/blksheep80/ex_pipedrive/issues/71)/[#95](https://github.com/blksheep80/ex_pipedrive/pull/95) ProductVariations, [#73](https://github.com/blksheep80/ex_pipedrive/issues/73)/[#96](https://github.com/blksheep80/ex_pipedrive/pull/96) Followers/DealParticipants/OrgRelationships, [#76](https://github.com/blksheep80/ex_pipedrive/issues/76)/[#94](https://github.com/blksheep80/ex_pipedrive/pull/94) CallLogs).
- **Wave C** ([#72](https://github.com/blksheep80/ex_pipedrive/issues/72)/[#97](https://github.com/blksheep80/ex_pipedrive/pull/97) Activity/Product Fields, [#75](https://github.com/blksheep80/ex_pipedrive/issues/75)/[#98](https://github.com/blksheep80/ex_pipedrive/pull/98) Goals, [#74](https://github.com/blksheep80/ex_pipedrive/issues/74)/[#99](https://github.com/blksheep80/ex_pipedrive/pull/99) Mailbox).
- **Admin meta** ([#77](https://github.com/blksheep80/ex_pipedrive/issues/77)/[#100](https://github.com/blksheep80/ex_pipedrive/pull/100)): Currencies, Recents, Roles, PermissionSets, Teams.
- **ActivityTypes CRUD** ([#87](https://github.com/blksheep80/ex_pipedrive/issues/87)/[#101](https://github.com/blksheep80/ex_pipedrive/pull/101)).
- **AUDIT refresh** ([#83](https://github.com/blksheep80/ex_pipedrive/issues/83)): gap map in [AUDIT.md](AUDIT.md); catch-all [#88](https://github.com/blksheep80/ex_pipedrive/issues/88) split into [#102](https://github.com/blksheep80/ex_pipedrive/issues/102)–[#107](https://github.com/blksheep80/ex_pipedrive/issues/107) (shipped). Tables aligned to `main` in [#126](https://github.com/blksheep80/ex_pipedrive/issues/126).

## Locked decisions

| Item | Decision |
|---|---|
| Hex / GitHub / OTP app | `ex_pipedrive` |
| Modules | `ExPipedrive.*` |
| Strategy | Fork of [tmecklem/line_drive](https://github.com/tmecklem/line_drive), evolve v2-first (do not rewrite from scratch) |
| Auth | API token **and** OAuth in core; OAuth TokenStore is pluggable (no Ecto in core) |
| HTTP | Tesla (keep unless strong reason to switch) |
| Core vs optional | Keep core lean. Optional Hex packages live in their own GitHub repos: [`ex_pipedrive_web`](https://github.com/blksheep80/ex_pipedrive_web), [`ex_pipedrive_oban`](https://github.com/blksheep80/ex_pipedrive_oban), [`ex_pipedrive_phoenix`](https://github.com/blksheep80/ex_pipedrive_phoenix). Independent of Überauth. |
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
- **Optional packages** (separate repos; clone next to this one for path deps): [`ex_pipedrive_web`](https://github.com/blksheep80/ex_pipedrive_web) (inbound webhook Plug), [`ex_pipedrive_oban`](https://github.com/blksheep80/ex_pipedrive_oban) (cursor sync workers), [`ex_pipedrive_phoenix`](https://github.com/blksheep80/ex_pipedrive_phoenix) (OAuth install).

## Issue backlog

Full tracker: https://github.com/blksheep80/ex_pipedrive/issues

**Start here (v0.1 foundation):** — all done (see Current state).

**v0.2 resources** (epic [#17](https://github.com/blksheep80/ex_pipedrive/issues/17)): done (#47–#52).

**v0.2 core track:** foundation + resources + Raw/Resource/rate-limit + Leads/Notes v1 + webhook surface are done.

**v0.3 coverage epic** [#66](https://github.com/blksheep80/ex_pipedrive/issues/66): **closed** — children done (resources, polish, packaging #82/#20/#21, Hex #85).

Priority order (remaining open): none. Hex **0.2.0** via [#124](https://github.com/blksheep80/ex_pipedrive/issues/124). Sibling Hex **0.1.0** via [#128](https://github.com/blksheep80/ex_pipedrive/issues/128). Optional packages split to their own GitHub repos via [#130](https://github.com/blksheep80/ex_pipedrive/issues/130).

**Done recently:** Phoenix OAuth helpers [#21](https://github.com/blksheep80/ex_pipedrive/issues/21) · `ex_pipedrive_oban` [#20](https://github.com/blksheep80/ex_pipedrive/issues/20) · `ex_pipedrive_web` [#82](https://github.com/blksheep80/ex_pipedrive/issues/82) · Dialyzer CI [#84](https://github.com/blksheep80/ex_pipedrive/issues/84) · Coverage #102–#107 · polish #78–#80/#86 · webhook event matrix [#81](https://github.com/blksheep80/ex_pipedrive/issues/81).

**Hex:** [`ex_pipedrive` 0.2.0](https://hex.pm/packages/ex_pipedrive) ([release v0.2.0](https://github.com/blksheep80/ex_pipedrive/releases/tag/v0.2.0)); first publish was `0.1.0` ([#85](https://github.com/blksheep80/ex_pipedrive/issues/85)). Siblings [`ex_pipedrive_web`](https://github.com/blksheep80/ex_pipedrive_web), [`ex_pipedrive_oban`](https://github.com/blksheep80/ex_pipedrive_oban), [`ex_pipedrive_phoenix`](https://github.com/blksheep80/ex_pipedrive_phoenix) Hex **0.1.1** (GitHub links on the split remotes). Republish add-ons via `.github/workflows/hex-publish-addons.yml` (`HEX_API_KEY` on this repo).

**Upstream / community:** LineDrive courtesy note [tmecklem/line_drive#33](https://github.com/tmecklem/line_drive/issues/33) ([#29](https://github.com/blksheep80/ex_pipedrive/issues/29) closed). Parity tracker [#26](https://github.com/blksheep80/ex_pipedrive/issues/26) closed; reopen if upstream moves.

## Suggested first agent prompt

```text
Open HANDOFF.md. Tracker is clear. Hex 0.2.0 shipped. Optional packages are separate GitHub repos. Next is product choice (Deal Coach, or Hex 0.3 later).
```

## How to resume

1. Read this file (and the `ex-pipedrive-session` skill if present).
2. `bd ready` for in-flight execution items.
3. Prefer GitHub issues for the broader backlog; create/claim a bead when starting concrete work.
4. Prefer this file + GitHub issues + beads over chat transcript memory.
