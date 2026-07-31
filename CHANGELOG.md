# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- `ExPipedrive.Users.find_users_by_name/3` matched atom-key response bodies
  (`%{success: true, data: data}`) and silently returned no matches against
  Jason-decoded (string-key) JSON. Now matches `%{"data" => data}` like every
  other resource module ([#67](https://github.com/blksheep80/ex_pipedrive/issues/67)).
- Preserve API-provided lead value currencies and leave bare numeric values
  currency-less.

### Added

### Added

- `ExPipedrive.ActivityFields` and `ExPipedrive.ProductFields` (API v2):
  `list_page/2`/`stream/2` over `/api/v2/{activity,product}Fields`, matching
  the existing Deal/Person/Organization field modules; `ExPipedrive.Fields`
  resolves custom-field hashes/labels for both
  ([#72](https://github.com/blksheep80/ex_pipedrive/issues/72)).
- Followers, deal participants, and organization relationships
  ([#73](https://github.com/blksheep80/ex_pipedrive/issues/73)):
  `ExPipedrive.Followers` (API v2) manages followers on deals, persons, and
  organizations via the shared `GET`/`POST`/`DELETE
  /api/v2/{deals,persons,organizations}/:id/followers` shape, with cursor
  `list_page/4`/`stream/4` and per-entity convenience wrappers;
  `ExPipedrive.DealParticipants` is an API v1 shim over
  `/api/v1/deals/:id/participants` (`ExPipedrive.DealParticipant` is distinct
  from the existing `ActivityParticipant`, which decodes activity payloads);
  `ExPipedrive.OrganizationRelationships` is an API v1 client over
  `/api/v1/organizationRelationships` (parent/related org hierarchies).
- `ExPipedrive.ProductVariations` (API v2): `list_page/3`, `stream/3`,
  `get/3` (client-side, since Pipedrive has no single-variation endpoint),
  `create/3`, `update/4`, `delete/3` against the nested
  `/api/v2/products/:id/variations` API; typed `ExPipedrive.ProductVariation`
  struct ([#71](https://github.com/blksheep80/ex_pipedrive/issues/71)).
- `ExPipedrive.CallLogs` (API v1): `list/2`, `get/2`, `create/2`,
  `add_recording/4` (multipart audio upload), `delete/2` against
  `/api/v1/callLogs`; typed `ExPipedrive.CallLog` struct with string ids
  (Pipedrive does not expose a call log update endpoint)
  ([#76](https://github.com/blksheep80/ex_pipedrive/issues/76)).
- `ExPipedrive.Files` (API v1): list/get/upload/download/update/delete plus
  Google Drive `create_remote/2` and `remote_link/2`; multipart uploads via
  `Tesla.Multipart` with deal/person/org/activity/product/lead/project link
  fields ([#68](https://github.com/blksheep80/ex_pipedrive/issues/68)).
- Labels API ([#70](https://github.com/blksheep80/ex_pipedrive/issues/70)):
  `ExPipedrive.DealLabels`, `PersonLabels`, `OrganizationLabels` manage label
  definitions via the API v2 `label_ids` field-options bulk endpoints
  (`POST`/`PATCH`/`DELETE /api/v2/{deal,person,organization}Fields/label_ids/options`);
  `ExPipedrive.LeadLabels` is an API v1 shim over the dedicated
  `/leadLabels` endpoint; `ExPipedrive.Labels` facade delegates across all
  four. Typed `ExPipedrive.Label` struct. Assigning/clearing labels on an
  entity remains a normal `label_ids` write via that entity's own
  `update/3` — there is no separate assign/clear endpoint.
- `ExPipedrive.Filters` (API v1): `list/2`, `get/2`, `create/2`, `update/3`,
  `delete/2` against `/api/v1/filters`; `conditions` accepted as a plain map
  ([#69](https://github.com/blksheep80/ex_pipedrive/issues/69)).
- `ExPipedrive.Users` (API v1): `me/1`, `get/2`, `list/2` (offset pagination),
  plus fake-server fixtures and tests for `me`/`get`/`list`/`find_users_by_name`
  ([#67](https://github.com/blksheep80/ex_pipedrive/issues/67)).

## [0.1.0] - 2026-07-31

First Hex release of **ExPipedrive**, a v2-first fork of
[LineDrive](https://github.com/tmecklem/line_drive).

### Added

#### Client foundation

- Pipedrive API **v2** client foundation (`Client`, `Request`, default `/api/v2`;
  explicit `api_version: :v1` where needed)
- Header API token auth (`x-api-token`); legacy query auth via `auth: :query`
- Structured `ExPipedrive.Error` / `Response` mapping
- `Page` / `Cursor.stream` for cursor pagination (limit clamped to 500)
- OAuth `Token` bundles, `ensure_fresh`, pluggable `TokenStore` (no Ecto in core)
- Rate-limit aware retry middleware + request telemetry
  (`ExPipedrive.Middleware.Retry`, `ExPipedrive.Middleware.Telemetry`,
  `ExPipedrive.RateLimit`); Client opts `:retry`, `:telemetry`, `:middleware`
- `ExPipedrive.Resource` behaviour + CRUD/list/stream helpers; `Products` and
  `Stages` adopt the pattern
- `ExPipedrive.Raw.request/4` escape hatch for unsupported endpoints

#### Resources (API v2 unless noted)

- Deals and Persons: list/stream (cursor), get, create, update; deal delete
- Organizations, Activities, Pipelines, Stages, Products: list/stream, get,
  create, update, delete (product variations deferred)
- Search: `ExPipedrive.Search` over `/api/v2/itemSearch` with cursor pages/stream
  and typed `SearchResult`
- Deal, Person, and Organization Fields list/page/stream plus
  `ExPipedrive.Fields` for resolving custom-field hashes and labels
- Leads / Notes: explicit **API v1** shims with map-based create helpers and
  `get/2`, `create/2`, `list/2` aliases
- Webhooks: `ExPipedrive.Webhooks` subscription list/create/delete (**API v1**
  management); `Webhook.Event` / `Webhook.Handler` inbound surface (optional Plug;
  Basic auth; package extract deferred)

#### Docs & tooling

- Fake Pipedrive server fixtures for v2 resources used in tests
- MVP README flows: stream open deals; create person then deal
- CI matrix, ExDoc, Hex publish-on-release workflow

### Changed

- Package / OTP app / modules rebranded from LineDrive → `ex_pipedrive` /
  `ExPipedrive`
- Core deps slimmed (Timex removed; Plug optional for webhooks only)
- Silent OTP Application/Registry coupling removed

### Migrating from LineDrive

1. Depend on `{:ex_pipedrive, "~> 0.1.0"}` instead of `:line_drive`.
2. Rename modules `LineDrive.*` → `ExPipedrive.*`.
3. Prefer `ExPipedrive.client/2` (header token) and v2 helpers
   (`Deals.stream/2`, `Deals.create/2`, `Persons.create/2`, …) over legacy v1
   list APIs.
4. OAuth: persist `ExPipedrive.Oauth.Token` via your `TokenStore` implementation;
   build clients with `Client.from_token/2` or `from_token_store/4`.
5. Use `ExPipedrive.Raw.request/4` for endpoints not yet wrapped.

[0.1.0]: https://github.com/blksheep80/ex_pipedrive/releases/tag/v0.1.0
