# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Labels API ([#70](https://github.com/blksheep80/ex_pipedrive/issues/70)):
  `ExPipedrive.DealLabels`, `PersonLabels`, `OrganizationLabels` manage label
  definitions via the API v2 `label_ids` field-options bulk endpoints
  (`POST`/`PATCH`/`DELETE /api/v2/{deal,person,organization}Fields/label_ids/options`);
  `ExPipedrive.LeadLabels` is an API v1 shim over the dedicated
  `/leadLabels` endpoint; `ExPipedrive.Labels` facade delegates across all
  four. Typed `ExPipedrive.Label` struct. Assigning/clearing labels on an
  entity remains a normal `label_ids` write via that entity's own
  `update/3` — there is no separate assign/clear endpoint.

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
