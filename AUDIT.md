# ExPipedrive API coverage audit

Status as of **2026-09-02**. Implemented modules vs Pipedrive OpenAPI tags
([API v1](https://developers.pipedrive.com/docs/api/v1/openapi.yaml),
[API v2](https://developers.pipedrive.com/docs/api/v2/openapi.yaml)).

Related: GitHub [#83](https://github.com/blksheep80/ex_pipedrive/issues/83)
(first gap map), catch-all [#88](https://github.com/blksheep80/ex_pipedrive/issues/88)
(split into #102–#107, all closed), epic
[#66](https://github.com/blksheep80/ex_pipedrive/issues/66) (closed),
[HANDOFF.md](HANDOFF.md). This refresh: [#126](https://github.com/blksheep80/ex_pipedrive/issues/126).

**How to use:** prefer this file for “what’s missing?”; prefer HANDOFF for
session sequencing; prefer GitHub issues for acceptance criteria.

---

## Snapshot

| Layer | Status |
|---|---|
| Hex | [`ex_pipedrive` 0.2.0](https://hex.pm/packages/ex_pipedrive) published |
| Client | Tesla + `Request` (default `/api/v2`, explicit `:v1`) + `x-api-token` |
| Errors / retry | `Error`, `Response`, `Middleware.Retry` / `Telemetry` |
| Escape hatches | `Raw.request/4`, pluggable OAuth `TokenStore` |
| Coverage epic | [#66](https://github.com/blksheep80/ex_pipedrive/issues/66) — **closed** |

**Decision key (resources):** **Done** · **Partial** · **Missing** · **Wontfix** · **Defer**

---

## Core platform (done)

| Area | Modules | Notes |
|---|---|---|
| HTTP | `Client`, `Request`, `Response`, `Error`, `Raw` | v2 default paths; v1 via `api_version: :v1` |
| Pagination | `Page`, `Cursor`, `PagedResult`, `Pagination`, `AdditionalData` | Cursor streams on v2 list resources |
| Resource helper | `Resource`, `WriteAttrs` | Adopted by Products/Stages/Deals/Persons/Orgs/Activities/Pipelines ([#78](https://github.com/blksheep80/ex_pipedrive/issues/78)) |
| OAuth | `Oauth`, `Oauth.Token`, `TokenStore` (+ Memory) | Phoenix install helpers in `ex_pipedrive_phoenix` ([#21](https://github.com/blksheep80/ex_pipedrive/issues/21)) |
| Webhooks | `Webhooks` (subscriptions), `Webhook.Event` / `Handler` in core; inbound Plug in `ex_pipedrive_web` | Event matrix ([#81](https://github.com/blksheep80/ex_pipedrive/issues/81)); package extract [#82](https://github.com/blksheep80/ex_pipedrive/issues/82) |
| Search | `Search` | v2 item search; explicit opts ([#24](https://github.com/blksheep80/ex_pipedrive/issues/24)) |

Historical LineDrive risks (query-param auth, string errors, OTP Registry) are
**resolved** for new code; see git history / closed foundation issues #3–#14.

---

## CRM resources — implemented

| Pipedrive tag | Preferred API | Module(s) | Coverage | Issue |
|---|---|---|---|---|
| Deals | v2 | `Deals`, `Deal` | CRUD + list/stream | done (#8) |
| DealProducts | v2 | `DealProducts`, `DealProduct` | nested under deal id | done (#102) |
| DealInstallments | v2 | `DealInstallments`, `DealInstallment` | Growth+; list requires `deal_ids` | done (#103) |
| Persons | v2 | `Persons`, `Person` | get/create/update + list/stream (no delete in client) | done (#9) |
| Organizations | v2 | `Organizations`, `Organization` | CRUD + list/stream | done (#47) |
| Activities | v2 + v1 | `Activities`, `Activity` | mix of collection/cursor + legacy | Partial — deepen if needed |
| Pipelines | v2 | `Pipelines`, `Pipeline` | CRUD + list/stream | done |
| Stages | v2 | `Stages`, `Stage` | CRUD + list/stream | done |
| Products | v2 | `Products`, `Product` | CRUD + list/stream | done |
| Product variations | v2 | `ProductVariations` | nested under products | done (#71) |
| Leads | v1 | `Leads`, `Lead` | get/create/update/list | done (#18) |
| LeadSources | v1 | `LeadSources`, `LeadSource` | fixed list (not user-editable) | done (#104) |
| Notes | v1 | `Notes`, `Note` | create/get/list; `get_all_org_notes` → `PagedResult` ([#86](https://github.com/blksheep80/ex_pipedrive/issues/86)) | done (#18) |
| Filters | v1 | `Filters`, `Filter` | CRUD | done (#69) |
| Files | v1 | `Files`, `File` | upload/download/CRUD + remote | done (#68) |
| CallLogs | v1 | `CallLogs`, `CallLog` | list/get/create/delete + recording | done (#76) |
| Goals | v1 | `Goals`, `Goal` | find/create/update/delete/results (no get-by-id) | done (#75) |
| Mailbox | v1 | `Mailbox`, mail structs | threads/messages read + thread update/delete | done (#74) |
| Users | v1 | `Users`, `User` | me/get/list/find | done (#67) |
| Currencies | v1 | `Currencies`, `Currency` | list + client-side get | done (#77) |
| Recents | v1 | `Recents`, `Recent` | list | done (#77) |
| Roles | v1 | `Roles`, `Role` | **read** list/get/assignments/pipelines/settings | Partial (#77 — writes → `Raw`) |
| PermissionSets | v1 | `PermissionSets` | read list/get/assignments | done (#77) |
| LegacyTeams | v1 | `Teams`, `Team` | **read** list/get/users | Partial (#77 — writes → `Raw`) |
| ActivityTypes | v1 | `ActivityTypes`, `ActivityType` | list/get/create/update/delete | done (#87) |
| Projects | v2 | `Projects`, `Project` | CRUD + list/stream + archived list | done (#105); phases/templates/fields/search/archive deferred |
| ProjectBoards | v2 | `ProjectBoards`, `ProjectBoard` | board lifecycle | done (#105) |
| Tasks | v2 (beta) | `Tasks`, `Task` | CRUD + list/stream | done (#106) |
| Webhooks (mgmt) | v1 | `Webhooks` | create/list/delete | done (#23) |
| Oauth | — | `Oauth` | code exchange + refresh | done (#6) |
| ItemSearch | v2 | `Search` | stream/search | done (#52) |
| OrganizationRelationships | v1 | `OrganizationRelationships` | CRUD | done (#73) |
| Followers / participants | v2 / v1 | `Followers`, `DealParticipants` | followers + deal participants | done (#73) |

### Fields & labels

| Tag | API | Module(s) | Status |
|---|---|---|---|
| DealFields / PersonFields / OrganizationFields | v2 | `*Fields` + `Fields` resolve | Done (#22) |
| ActivityFields / ProductFields | v2 | `ActivityFields`, `ProductFields` | Done (#72) |
| LeadFields | v1 | `LeadFields` + `Fields` resolve | Done (#104) |
| NoteFields | v1 | `NoteFields` | Done (#107) |
| ProjectFields | v2 | — | **Missing** — deferred with Projects cluster |
| Deal / Person / Org / Lead labels | v2 field options + v1 LeadLabels | `Labels`, `*Labels` | Done (#70) |

---

## Pipedrive tags — remaining gaps

OpenAPI tags as of 2026-07-31; implementation status as of 2026-09-02.
Prefer **v2** when both exist. Use `Raw.request/4` until a module exists.
Do **not** file new coverage tickets unless a consumer needs the endpoint.

| Tag | v1 | v2 | Decision | Notes |
|---|---|---|---|---|
| **ProjectPhases** | yes | yes | **Missing** | Deferred in `Projects` (#105 shipped boards + project CRUD only) |
| **ProjectTemplates** | yes | yes | **Missing** | Same |
| **ProjectFields** | — | yes | **Missing** | Same |
| Project search / archive | — | yes | **Missing** | Documented deferred on `ExPipedrive.Projects` |
| **Channels** | yes | — | **Defer** | Messaging integrations; niche |
| **Meetings** | yes | — | **Defer** | Calendar/meetings product surface |
| **UserConnections** | yes | — | **Defer** | Account linking |
| **UserSettings** | yes | — | **Defer** | Per-user prefs |
| **Billing** | yes | — | **Wontfix** | Account billing; not an SDK target |
| **Beta** | — | yes | **Wontfix** | Unstable; use `Raw` if needed (Tasks is the one beta tag we wrapped) |
| Activities (deeper) | yes | yes | **Partial** | Expand only if callers need missing endpoints |
| Roles / Teams writes | yes | — | **Partial** | Documented deferred; `Raw` OK |
| Persons delete | v2 | yes | **Partial** | Add if requested |

Shipped from former catch-all [#88](https://github.com/blksheep80/ex_pipedrive/issues/88):
DealProducts (#102), DealInstallments (#103), LeadFields + LeadSources (#104),
Projects + ProjectBoards (#105), Tasks (#106), NoteFields (#107).

---

## Polish / packages (tracked outside #88)

| Work | Issue |
|---|---|
| Finish `Resource` adoption | [#78](https://github.com/blksheep80/ex_pipedrive/issues/78) — core CRM modules done; nested/v1 may stay exceptions |
| Facade / dual twin cleanup | [#79](https://github.com/blksheep80/ex_pipedrive/issues/79) — soft-deprecated; remove twins in a later major |
| Webhook event expansion | [#81](https://github.com/blksheep80/ex_pipedrive/issues/81) — done |
| `ex_pipedrive_web` package | [#82](https://github.com/blksheep80/ex_pipedrive/issues/82) — done; Hex ([#128](https://github.com/blksheep80/ex_pipedrive/issues/128)); repo [`ex_pipedrive_web`](https://github.com/blksheep80/ex_pipedrive_web) ([#130](https://github.com/blksheep80/ex_pipedrive/issues/130)) |
| Dialyzer in CI | [#84](https://github.com/blksheep80/ex_pipedrive/issues/84) — done (baseline flags + PLT cache) |
| Normalize list return shapes | [#86](https://github.com/blksheep80/ex_pipedrive/issues/86) — done (`PagedResult` + docs) |
| Oban sync package | [#20](https://github.com/blksheep80/ex_pipedrive/issues/20) — done; Hex ([#128](https://github.com/blksheep80/ex_pipedrive/issues/128)); repo [`ex_pipedrive_oban`](https://github.com/blksheep80/ex_pipedrive_oban) ([#130](https://github.com/blksheep80/ex_pipedrive/issues/130)) |
| Phoenix OAuth helpers | [#21](https://github.com/blksheep80/ex_pipedrive/issues/21) — done; Hex ([#128](https://github.com/blksheep80/ex_pipedrive/issues/128)); repo [`ex_pipedrive_phoenix`](https://github.com/blksheep80/ex_pipedrive_phoenix) ([#130](https://github.com/blksheep80/ex_pipedrive/issues/130)); independent of Überauth |
| Hex 0.2.0 | [#124](https://github.com/blksheep80/ex_pipedrive/issues/124) — done |
| Upstream LineDrive notify | [#29](https://github.com/blksheep80/ex_pipedrive/issues/29) — done ([tmecklem/line_drive#33](https://github.com/tmecklem/line_drive/issues/33)) |
| Upstream parity tracker | [#26](https://github.com/blksheep80/ex_pipedrive/issues/26) — closed 2026-09-02; reopen if LineDrive moves |

---

## Test / tooling notes

- Fake server: large route mirror on fixed port `4006` (`PipedriveClientCase`); prefer appending handlers over rewriting.
- Quality gate: `mix test`, `mix format --check-formatted`, `mix credo --strict`, `mix dialyzer`.
- Dialyzer: CI gate on the primary matrix cell (Elixir 1.17) with PLT cache ([#84](https://github.com/blksheep80/ex_pipedrive/issues/84)). Default flags only; stricter Dialyzer flags are a later tightening.
- Doctor: doc coverage gate in CI (primary matrix cell).

---

## Recommended next

Do **not** invent SDK endpoints. Remaining gaps above wait for a real caller
(Deal Coach or similar). Optional packages are separate GitHub repos
([#130](https://github.com/blksheep80/ex_pipedrive/issues/130)).
