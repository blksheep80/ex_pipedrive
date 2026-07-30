# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Activities v2: list/stream (cursor), get, create, update, delete; v2 fake fixtures

## [0.1.0] - 2026-07-30

First Hex release of **ExPipedrive**, a v2-first fork of
[LineDrive](https://github.com/tmecklem/line_drive).

### Added

- Pipedrive API **v2** client foundation (`Client`, `Request`, default `/api/v2`)
- Header API token auth (`x-api-token`); legacy query auth via `auth: :query`
- Structured `ExPipedrive.Error` / `Response` mapping
- Deals and Persons v2: list/stream (cursor), get, create, update; deal delete
- `Page` / `Cursor.stream` for cursor pagination (limit clamped to 500)
- OAuth `Token` bundles, `ensure_fresh`, pluggable `TokenStore` (no Ecto in core)
- Fake Pipedrive server fixtures for v2 deals/persons
- MVP README flows: stream open deals; create person then deal

### Changed

- Package / OTP app / modules rebranded from LineDrive → `ex_pipedrive` / `ExPipedrive`
- Core deps slimmed (Timex removed; Plug optional for webhooks only)
- Silent OTP Application/Registry coupling removed

### Migrating from LineDrive

1. Depend on `{:ex_pipedrive, "~> 0.1.0"}` instead of `:line_drive`.
2. Rename modules `LineDrive.*` → `ExPipedrive.*`.
3. Prefer `ExPipedrive.client/2` (header token) and v2 helpers
   (`Deals.stream/2`, `Deals.create/2`, `Persons.create/2`) over legacy v1 list APIs.
4. OAuth: persist `ExPipedrive.Oauth.Token` via your `TokenStore` implementation;
   build clients with `Client.from_token/2` or `from_token_store/4`.

Inherited LineDrive resources (orgs, activities, leads, notes, pipelines, …)
still call API v1 until migrated in later releases.

[0.1.0]: https://github.com/blksheep80/ex_pipedrive/releases/tag/v0.1.0
