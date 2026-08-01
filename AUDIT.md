# ExPipedrive API coverage audit

Status as of **2026-07-31**. Replaces the inherited LineDrive keep/adapt inventory
with a **current gap map**: implemented modules vs Pipedrive OpenAPI tags
([API v1](https://developers.pipedrive.com/docs/api/v1/openapi.yaml),
[API v2](https://developers.pipedrive.com/docs/api/v2/openapi.yaml)).

Related: GitHub [#83](https://github.com/blksheep80/ex_pipedrive/issues/83),
epic [#66](https://github.com/blksheep80/ex_pipedrive/issues/66),
catch-all [#88](https://github.com/blksheep80/ex_pipedrive/issues/88),
[HANDOFF.md](HANDOFF.md).

**How to use:** prefer this file for “what’s missing?”; prefer HANDOFF for
session sequencing; prefer GitHub issues for acceptance criteria.

---

## Snapshot

| Layer | Status |
|---|---|
| Hex | [`ex_pipedrive` 0.1.0](https://hex.pm/packages/ex_pipedrive) published |
| Client | Tesla + `Request` (default `/api/v2`, explicit `:v1`) + `x-api-token` |
| Errors / retry | `Error`, `Response`, `Middleware.Retry` / `Telemetry` |
| Escape hatches | `Raw.request/4`, pluggable OAuth `TokenStore` |
| Coverage epic | [#66](https://github.com/blksheep80/ex_pipedrive/issues/66) — Waves A–C + #77/#87 done |

**Decision key (resources):** **Done** · **Partial** · **Missing** · **Wontfix** · **Defer**

---

## Core platform (done)

| Area | Modules | Notes |
|---|---|---|
| HTTP | `Client`, `Request`, `Response`, `Error`, `Raw` | v2 default paths; v1 via `api_version: :v1` |
| Pagination | `Page`, `Cursor`, `PagedResult`, `Pagination`, `AdditionalData` | Cursor streams on v2 list resources |
| Resource helper | `Resource`, `WriteAttrs` | Adopted by Products/Stages/Deals/Persons/Orgs/Activities/Pipelines ([#78](https://github.com/blksheep80/ex_pipedrive/issues/78)) |
| OAuth | `Oauth`, `Oauth.Token`, `TokenStore` (+ Memory) | Phoenix helpers deferred [#21](https://github.com/blksheep80/ex_pipedrive/issues/21) |
| Webhooks | `Webhooks` (subscriptions), `Webhook.Event` / `Handler`, `Incoming.Handler` | Event expansion [#81](https://github.com/blksheep80/ex_pipedrive/issues/81); extract package [#82](https://github.com/blksheep80/ex_pipedrive/issues/82) |
| Search | `Search` | v2 item search; explicit opts ([#24](https://github.com/blksheep80/ex_pipedrive/issues/24)) |

Historical LineDrive risks (query-param auth, string errors, OTP Registry) are
**resolved** for new code; see git history / closed foundation issues #3–#14.

---

## CRM resources — implemented

| Pipedrive tag | Preferred API | Module(s) | Coverage | Issue |
|---|---|---|---|---|
| Deals | v2 | `Deals`, `Deal` | CRUD + list/stream | done (#8) |
| Persons | v2 | `Persons`, `Person` | get/create/update + list/stream (no delete in client) | done (#9) |
| Organizations | v2 | `Organizations`, `Organization` | CRUD + list/stream | done (#47) |
| Activities | v2 + v1 | `Activities`, `Activity` | mix of collection/cursor + legacy | Partial — deepen if needed |
| Pipelines | v2 | `Pipelines`, `Pipeline` | CRUD + list/stream | done |
| Stages | v2 | `Stages`, `Stage` | CRUD + list/stream | done |
| Products | v2 | `Products`, `Product` | CRUD + list/stream | done |
| Product variations | v2 | `ProductVariations` | nested under products | done (#71) |
| Leads | v1 | `Leads`, `Lead` | get/create/update/list | done (#18) |
| Notes | v1 | `Notes`, `Note` | create/get/list; `get_all_org_notes` → `PagedResult` ([#86](https://github.com/blksheep80/ex_pipedrive/issues/86)) | Yes |
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
| LeadFields | v1 | — | **Missing** → [#104](https://github.com/blksheep80/ex_pipedrive/issues/104) |
| NoteFields | v1 | — | **Missing** → [#107](https://github.com/blksheep80/ex_pipedrive/issues/107) |
| ProjectFields | v2 | — | **Missing** (with Projects) → [#105](https://github.com/blksheep80/ex_pipedrive/issues/105) |
| Deal / Person / Org / Lead labels | v2 field options + v1 LeadLabels | `Labels`, `*Labels` | Done (#70) |

---

## Pipedrive tags — gaps (drive #88)

Confirmed against OpenAPI tags (2026-07-31). Prefer **v2** when both exist.

| Tag | v1 | v2 | Decision | Notes / follow-up |
|---|---|---|---|---|
| **DealProducts** | — | yes | **Missing** — must-have | [#102](https://github.com/blksheep80/ex_pipedrive/issues/102) |
| **DealInstallments** | — | yes | **Missing** — should-have | [#103](https://github.com/blksheep80/ex_pipedrive/issues/103) |
| **LeadFields** | yes | — | **Missing** — must-have | [#104](https://github.com/blksheep80/ex_pipedrive/issues/104) |
| **LeadSources** | yes | — | **Missing** — should-have | with [#104](https://github.com/blksheep80/ex_pipedrive/issues/104) |
| **NoteFields** | yes | — | **Missing** — nice-to-have | [#107](https://github.com/blksheep80/ex_pipedrive/issues/107) |
| **Projects** | yes | yes | **Missing** — must-have if productizing Projects | [#105](https://github.com/blksheep80/ex_pipedrive/issues/105) |
| **ProjectBoards** | yes | yes | **Missing** | with [#105](https://github.com/blksheep80/ex_pipedrive/issues/105) |
| **ProjectPhases** | yes | yes | **Missing** | with [#105](https://github.com/blksheep80/ex_pipedrive/issues/105) |
| **ProjectTemplates** | yes | yes | **Missing** | with [#105](https://github.com/blksheep80/ex_pipedrive/issues/105) |
| **ProjectFields** | — | yes | **Missing** | with [#105](https://github.com/blksheep80/ex_pipedrive/issues/105) |
| **Tasks** | yes | yes | **Missing** — should-have | [#106](https://github.com/blksheep80/ex_pipedrive/issues/106) |
| **Channels** | yes | — | **Defer** | Messaging integrations; niche |
| **Meetings** | yes | — | **Defer** | Calendar/meetings product surface |
| **UserConnections** | yes | — | **Defer** | Account linking |
| **UserSettings** | yes | — | **Defer** | Per-user prefs |
| **Billing** | yes | — | **Wontfix** | Account billing; not an SDK target |
| **Beta** | — | yes | **Wontfix** | Unstable; use `Raw` if needed |
| Activities (deeper) | yes | yes | **Partial** | Expand only if callers need missing endpoints |
| Roles / Teams writes | yes | — | **Partial** | Documented deferred; `Raw` OK |
| Persons delete | v2 | yes | **Partial** | Add if requested |

---

## Polish / packages (tracked outside #88)

| Work | Issue |
|---|---|
| Finish `Resource` adoption | [#78](https://github.com/blksheep80/ex_pipedrive/issues/78) — core CRM modules done; nested/v1 may stay exceptions |
| Facade / dual twin cleanup | [#79](https://github.com/blksheep80/ex_pipedrive/issues/79) — soft-deprecated; remove twins in a later major |
| Webhook event expansion | [#81](https://github.com/blksheep80/ex_pipedrive/issues/81) |
| `ex_pipedrive_web` package | [#82](https://github.com/blksheep80/ex_pipedrive/issues/82) |
| Dialyzer in CI | [#84](https://github.com/blksheep80/ex_pipedrive/issues/84) |
| Normalize list return shapes | [#86](https://github.com/blksheep80/ex_pipedrive/issues/86) — done (`PagedResult` + docs) |
| Oban sync package | [#20](https://github.com/blksheep80/ex_pipedrive/issues/20) |
| Phoenix OAuth helpers | [#21](https://github.com/blksheep80/ex_pipedrive/issues/21) |
| Upstream LineDrive notify | [#29](https://github.com/blksheep80/ex_pipedrive/issues/29) **HOLD** until #66 substantially done |
| Upstream parity tracker | [#26](https://github.com/blksheep80/ex_pipedrive/issues/26) |

---

## Test / tooling notes

- Fake server: large route mirror on fixed port `4006` (`PipedriveClientCase`); prefer appending handlers over rewriting.
- Quality gate: `mix test`, `mix format --check-formatted`, `mix credo --strict`.
- Dialyzer: local-only until [#84](https://github.com/blksheep80/ex_pipedrive/issues/84).
- Doctor: doc coverage gate in CI (primary matrix cell).

---

## Recommended next coverage order

1. [#102](https://github.com/blksheep80/ex_pipedrive/issues/102) Deal products (+ [#103](https://github.com/blksheep80/ex_pipedrive/issues/103) installments if cheap).
2. [#104](https://github.com/blksheep80/ex_pipedrive/issues/104) LeadFields (+ LeadSources).
3. [#105](https://github.com/blksheep80/ex_pipedrive/issues/105) Projects cluster **or** [#106](https://github.com/blksheep80/ex_pipedrive/issues/106) Tasks — product decision.
4. [#107](https://github.com/blksheep80/ex_pipedrive/issues/107) NoteFields.
5. Polish wave (#78, #86, #81) interleaved with Hex `0.2.0` when coverage feels shippable.

Catch-all checklist: [#88](https://github.com/blksheep80/ex_pipedrive/issues/88). Do **not** invent endpoints — cite Pipedrive docs / OpenAPI when filing children.
