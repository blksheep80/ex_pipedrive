# Inherited LineDrive audit

Status as of 2026-07-30. Tracks keep/adapt/deprecate/remove decisions for code inherited from [tmecklem/line_drive](https://github.com/tmecklem/line_drive) before v2 refactors begin.

Related: GitHub [#2](https://github.com/blksheep80/ex_pipedrive/issues/2), [HANDOFF.md](HANDOFF.md).

## Summary

| Category | Count | Default decision |
|---|---|---|
| Resource API modules | 12 | Adapt (v1 fallback) |
| Entity structs | 16 | Adapt for v2 shapes |
| Auth (token + OAuth) | 2 modules | Adapt |
| Pagination helpers | 3 modules | Adapt → cursor (#7) |
| Webhook / incoming | 3 modules | Deprecate from core |
| OTP Application / Registry | 1 module | Remove coupling (#14) |
| Test fakes + case | 13 modules | Rebuild for v2 (#12) |
| Integration tests | 31 files | Adapt with v2 fixtures |

**Decision key:** **Keep** = use as-is short term · **Adapt** = evolve for v2-first · **Deprecate** = move out of core / phase out · **Remove** = delete when replacement lands

---

## Cross-cutting v1 assumptions (v2 blockers)

These appear across most inherited code and must be addressed before v2 is default:

1. **Paths** — all resources call `/api/v1/*` with camelCase segments (`dealFields`, `activityTypes`).
2. **Auth** — `ExPipedrive.client/2` sends `api_token` as a query param; v2 expects `x-api-token` header ([#4](https://github.com/blksheep80/ex_pipedrive/issues/4)).
3. **Response envelope** — `{success, data, error, additional_data, related_objects}` with string keys; errors are raw strings or Tesla env tuples ([#3](https://github.com/blksheep80/ex_pipedrive/issues/3), [#5](https://github.com/blksheep80/ex_pipedrive/issues/5)).
4. **Pagination** — offset `start`/`limit` via `additional_data.pagination`; cursor (`next_cursor`) only on `activities/collection` ([#7](https://github.com/blksheep80/ex_pipedrive/issues/7)).
5. **Search responses** — nested `data.items[].item` unwrap, not `PagedResult`.
6. **Entity shapes** — v1 nested objects (e.g. deal `org_id` as mini-map), denormalized name fields, non-ISO8601 datetimes (`"YYYY-MM-DD HH:MM:SS"`) silently parse as `nil` ([#11](https://github.com/blksheep80/ex_pipedrive/issues/11)).
7. **Write bodies** — partial `Jason.Encoder` on structs defines POST/PUT payload shape.
8. **Webhooks** — v1 payload (`current`/`previous`/`meta`); Plug router is optional (#27); host supplies `on_event/1` ([#14](https://github.com/blksheep80/ex_pipedrive/issues/14)).

---

## Subsystem inventory

### Client facade and HTTP

| Subsystem | Location | Decision | v1 assumptions | Follow-up |
|---|---|---|---|---|
| Root facade + delegates | `lib/ex_pipedrive.ex` | **Adapt** | Query-param token client; `build_client/4` one-shot OAuth refresh | #3, #4 |
| Tesla per resource module | all `*.ex` resource modules | **Keep** | `use Tesla`; JSON via Jason; PathParams middleware | #3 |
| `@callback` without `@behaviour` | resource modules | **Remove** | Dead mock interface, never wired | #3 cleanup |

### Auth

| Subsystem | Location | Decision | v1 assumptions | Follow-up |
|---|---|---|---|---|
| API token client | `ExPipedrive.client/2` | **Adapt** | `Tesla.Middleware.Query` with `api_token` | #4 |
| OAuth helpers | `lib/ex_pipedrive/oauth.ex` | **Adapt** | Fixed `oauth.pipedrive.com` URLs; Basic auth; form bodies; bare token strings (no expiry metadata) | #3, TokenStore (HANDOFF) |
| OAuth client builder | `ExPipedrive.build_client/4` | **Adapt** | Refresh once at build; Bearer only; no 401 retry | #3, TokenStore |

**Risky behavior to preserve temporarily**

- Query-param auth until #4 ships with v1 compat.
- `Oauth.get_refresh_token/4` uses `{:ok, resp} = post(...)` — **raises on HTTP failure**; callers rely on happy path.
- `Oauth.refresh_access_token/3` maps 401 → `:refresh_token_expired` (only structured error in codebase).

### Pagination and list responses

| Subsystem | Location | Decision | v1 assumptions | Follow-up |
|---|---|---|---|---|
| `Pagination` | `lib/ex_pipedrive/pagination.ex` | **Adapt** | Offset: `start`, `limit`, `more_items_in_collection` | #7 |
| `AdditionalData` | `lib/ex_pipedrive/additional_data.ex` | **Adapt** | Dual model: offset `pagination` **or** cursor `next_cursor` | #7 |
| `PagedResult` | `lib/ex_pipedrive/paged_result.ex` | **Adapt** | v1 envelope wrapper; `related_objects` lookup uses atom key on string map → always `[]` | #3, #5 |

**Risky behavior to preserve temporarily**

- Default limits (`50` most resources, `100` activities, `20` org notes) — tests assert these.
- Activities module is the **only** cursor consumer; `list_own_activities` still uses offset.

### Struct layer

| Subsystem | Location | Decision | v1 assumptions | Follow-up |
|---|---|---|---|---|
| `Structable` macro | `lib/ex_pipedrive/structable.ex` | **Keep → adapt** | ISO8601 date/time only; selective key atomization | #11 |
| Entity structs (×16) | `deal.ex`, `person.ex`, … | **Adapt** | v1 field names; nested ID objects; `original_object` escape hatch | #11 |

Entities: `Deal`, `Person`, `Organization`, `Lead`, `LeadPerson`, `LeadOrganization`, `LeadValue`, `Activity`, `ActivityParticipant`, `ActivityType`, `Note`, `Pipeline`, `User`, `Field`, `FieldOption`, plus metadata structs above.

**Risky behavior to preserve temporarily**

- `original_object` on several entities — downstream may read custom fields from raw API map.
- `Person.new_from_search/1` — search returns different shape than get.
- `Organization.new/1` — passes through non-map values for nested ID compat.
- `LeadValue.new/1` on integer — hard-codes `"USD"`.
- Partial `Jason.Encoder` on write structs defines POST body shape.

### Resource APIs (all v1 today)

| Module | Endpoints | Writes | Decision | Follow-up |
|---|---|---|---|---|
| `Deals` | get, list, search | — | **Adapt** | #8, #24 |
| `Persons` | get, create, list, search | create | **Adapt** | #9 |
| `Organizations` | get, create, list, search, update | create, update | **Adapt** | #11 |
| `Leads` | get, create, list, search | create | **Adapt** | #11 |
| `Activities` | add, list (collection), list_own | add | **Adapt** | #7, #11 |
| `Notes` | add, list, get_all_org_notes | add | **Adapt** | #11 |
| `Pipelines` | list, list_pipeline_deals | — | **Adapt** | #11, #25 |
| `Users` | find_by_name | — | **Deprecate or adapt** | #11 |
| `DealFields` | list | — | **Adapt** | #11 |
| `PersonFields` | list | — | **Adapt** | #11 |
| `OrganizationFields` | list | — | **Adapt** | #11 |
| `ActivityTypes` | list | — | **Adapt** | #11 |

**Shared v1 response pattern:** match `%{"success" => true, "data" => ...}`; error → `{:error, message_string}`.

**Notable quirks**

- `Activities.list_activities/2` → `/activities/collection` (cursor); `list_own_activities/2` → `/activities` (offset).
- `Notes.get_all_org_notes/3` returns flat list, not `PagedResult`.
- `Pipelines.list_pipelines/1` returns bare list; `list_pipeline_deals/2` has no pagination.
- `Users.find_users_by_name/3` pattern-matches **atom keys** (`%{success: true}`) — inconsistent with other modules; likely broken against JSON-decoded bodies. **No tests.**

### Webhooks and OTP

| Subsystem | Location | Decision | v1 assumptions | Follow-up |
|---|---|---|---|---|
| Webhook Plug router | `incoming/handler.ex` | **Deprecate from core** | `POST /webhook`; Basic auth; `on_event/1` callback (no Registry) | future `ex_pipedrive_web` |
| Deal webhook handler | `incoming/deal_handler.ex` | **Deprecate from core** | `"updated.deal"`; MapSet diff on map pairs | optional package |
| Person webhook handler | `incoming/person_handler.ex` | **Deprecate from core** | `"updated.person"` only; no tests | optional package |
| Registry event bus | ~~`application.ex` + handler~~ | **Removed from core** (#14) | Host supplies `on_event/1` callback | optional package |
| OTP Application | ~~`lib/ex_pipedrive/application.ex`~~ | **Removed** (#14) | No `mod` callback; core is dependency-only | — |

**Risky behavior to preserve temporarily**

- Always HTTP 200 (Pipedrive retry semantics).
- Warning-level log on every Registry dispatch.
- Synchronous `send/2` to registered pids.

### Test infrastructure

| Subsystem | Location | Decision | v1 assumptions | Follow-up |
|---|---|---|---|---|
| Fake Pipedrive server | `test/support/fake_pipedrive_server.ex` | **Rebuild** | Full v1 route mirror on port 4006; no auth validation | #12 |
| Fake API handlers (×11) | `test/support/fake_*_api_handler.ex` | **Rebuild** | Static JSON fixtures; v1 envelopes | #12 |
| `PipedriveClientCase` | `test/support/pipedrive_client_case.ex` | **Adapt** | Cowboy on `:4006`; query-param client | #12 |
| Integration tests (×31) | `test/**/*.exs` | **Adapt** | Assert v1 `PagedResult`, offset pagination | #8, #9, #10, #12 |

**Test gaps:** no OAuth tests, no `Users` tests, no `Incoming.Handler` HTTP test, no `PersonHandler` test.

### Dependencies

Reviewed for [#27](https://github.com/blksheep80/ex_pipedrive/issues/27) (2026-07-30). Core stays free of Phoenix/Oban; Plug is not a transitive runtime requirement.

| Dep | Env | Used by | Decision | Notes |
|---|---|---|---|---|
| `tesla` | runtime | All HTTP | **Keep** | Locked HTTP client (HANDOFF) |
| `jason` | runtime | JSON | **Keep** | Required with Tesla JSON |
| `typed_struct` | runtime | Entities | **Keep (v0.1)** | Native Elixir has no drop-in replacement; removing means rewriting entities to `defstruct` + `@type`. Revisit only if Hex weight or maintenance cost justifies a dedicated migration (#32) |
| `plug` | **optional** | `Incoming.Handler` only | **Optional** | Consumers add `{:plug, ">= 1.16.0"}` for webhooks; module gated with `Code.ensure_loaded?(Plug.Router)` |
| `plug_cowboy` | test | Fake server | **Keep (test)** | Rebuild with #12 |
| `timex` | — | — | **Removed** | Was test-only; fakes use `Date.to_iso8601/1` |
| `credo`, `dialyxir`, `ex_doc`, `doctor` | dev/test | Tooling | **Keep** | See [Tooling decisions](#tooling-decisions-32) |
| `sobelow` | — | — | **Skip in core** | Phoenix/Plug-oriented; revisit with `ex_pipedrive_web` |
| `ex_machina` | — | — | **Skip** | Ecto-oriented factories; no value without Ecto in core |
| `faker` | — | — | **Defer** | Fake-server JSON fixtures are enough for now |
| Phoenix / Oban | — | — | **Out of core** | Future optional packages |

### Tooling decisions (#32)

| Tool | Decision |
|---|---|
| TypedStruct | **Keep** for v0.1 entities (see deps table). Migration notes: replace `use TypedStruct` with `defstruct` + `@type t :: %__MODULE__{...}` per entity; keep `Structable` transforms. |
| `doctor` | **Added** — `.doctor.exs` overall doc coverage gate (≥40%); wired into local quality gate + CI (primary OTP/Elixir cell). Module-level floors soft until v1 resources are documented. |
| Dialyzer | **Local / optional** — `dialyxir` remains a dep; not in CI yet (PLT build cost + inherited noisy types). Run `mix dialyzer` before releases; enable CI once PLT caching and baseline clean-up land. |
| Sobelow / ExMachina | **Wontfix in core** (see deps table). |

---

## Risky behavior — preserve during migration

| Behavior | Why | Remove when |
|---|---|---|
| Query-param `api_token` | Existing client contract | #4 |
| `original_object` on entities | Custom field access without schema | #11 |
| Dual activity list functions | Different v1 endpoints / pagination | v2 activities API |
| `Person.new_from_search/1` | Search shape differs from get | #9 |
| Webhook 200 + Registry dispatch | Pipedrive retry + subscribers | optional package |
| Offset pagination defaults | Test assertions | #7 |
| String error messages | `{:ok,_} \| {:error,_}` contract | #5 |
| Fake v1 server fixtures | 31 tests depend on them | #12 |

---

## Follow-up issue map

| Work | Issue |
|---|---|
| v2 client foundation + routing | [#3](https://github.com/blksheep80/ex_pipedrive/issues/3) |
| Header-based token auth | [#4](https://github.com/blksheep80/ex_pipedrive/issues/4) |
| Structured `ExPipedrive.Error` | [#5](https://github.com/blksheep80/ex_pipedrive/issues/5) |
| Cursor pagination + Stream | [#7](https://github.com/blksheep80/ex_pipedrive/issues/7) |
| Deals v2 | [#8](https://github.com/blksheep80/ex_pipedrive/issues/8) |
| Persons v2 | [#9](https://github.com/blksheep80/ex_pipedrive/issues/9) |
| MVP docs + tests | [#10](https://github.com/blksheep80/ex_pipedrive/issues/10) |
| Entity structs for v2 shapes | [#11](https://github.com/blksheep80/ex_pipedrive/issues/11) |
| Rebuild fake-server fixtures | [#12](https://github.com/blksheep80/ex_pipedrive/issues/12) |
| Remove OTP Application/Registry coupling | [#14](https://github.com/blksheep80/ex_pipedrive/issues/14) |
| Upstream search options carryover | [#24](https://github.com/blksheep80/ex_pipedrive/issues/24) |
| Upstream weighted pipeline history | [#25](https://github.com/blksheep80/ex_pipedrive/issues/25) |
| Slim core dependencies | [#27](https://github.com/blksheep80/ex_pipedrive/issues/27) |

**Recommended new issues (not yet filed):**

- Webhooks → optional `ex_pipedrive_web` package (extract Plug handlers + Registry).
- OAuth TokenStore middleware (HANDOFF locked decision: pluggable, no Ecto in core).
- Fix `Users` module atom-key bug + add tests.

---

## Recommended sequencing (post-audit)

Per [HANDOFF.md](HANDOFF.md) foundation order:

1. ~~#1 Rebrand~~ (done)
2. ~~#2 Audit~~ (this doc)
3. #14 Remove silent OTP/Registry coupling
4. ~~#27 Slim core dependencies~~ (done — Timex removed; Plug optional)
5. #3 v2-first client foundation
6. #4, #5, #11, #12, #7, #8, #9, #10

Do not start API v2 resource work until the lean core surface is clear (#14/#27 done) or the human explicitly scopes earlier.
