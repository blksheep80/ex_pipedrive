# ExPipedrive

Elixir client for the [Pipedrive](https://www.pipedrive.com) CRM API.

This repository is a fork of [tmecklem/line_drive](https://github.com/tmecklem/line_drive), rebranded as **ExPipedrive** (`ex_pipedrive` / `ExPipedrive.*`) and evolving toward a **v2-first** SDK.

> **Status:** Hex package `ex_pipedrive` **0.1.0** — v2-first client with Deals,
> Persons, Organizations, Activities, Pipelines, Stages, Products, Search, Fields,
> OAuth TokenStore, Raw escape hatch, and webhook helpers. Further API coverage is
> tracked in [issue #66](https://github.com/blksheep80/ex_pipedrive/issues/66) and
> [HANDOFF.md](https://github.com/blksheep80/ex_pipedrive/blob/main/HANDOFF.md).

## Goals

- Pipedrive API v2 as the default, with explicit v1 fallback where needed
- API token **and** OAuth (pluggable TokenStore; no Ecto in core)
- Lean core library; optional `ex_pipedrive_web` for inbound webhook Plug,
  later Oban sync / Phoenix OAuth helpers
- Broad resource coverage over time (see epic [#66](https://github.com/blksheep80/ex_pipedrive/issues/66))

## Installation

```elixir
def deps do
  [
    {:ex_pipedrive, "~> 0.1.0"}
  ]
end
```

For inbound webhook Plug helpers, also add [`ex_pipedrive_web`](packages/ex_pipedrive_web):

```elixir
{:ex_pipedrive_web, "~> 0.1.0"}
```

Docs: [https://hexdocs.pm/ex_pipedrive](https://hexdocs.pm/ex_pipedrive)

To depend on `main` instead of a Hex release:

```elixir
def deps do
  [
    {:ex_pipedrive, github: "blksheep80/ex_pipedrive"}
  ]
end
```

Core runtime deps are Tesla, Jason, Telemetry, and TypedStruct. Plug is **not**
a core dependency.

## Usage

```elixir
client = ExPipedrive.client("your-api-token", "your-company.pipedrive.com")
```

### Stream open deals (API v2 cursor pagination)

```elixir
client
|> ExPipedrive.Deals.stream(status: "open", limit: 500)
|> Stream.each(&IO.inspect/1)
|> Stream.run()
```

### Create a person, then a deal

```elixir
{:ok, person} =
  ExPipedrive.Persons.create(client, %{
    name: "Jane Doe",
    emails: [%{label: "work", value: "jane@example.com", primary: true}]
  })

{:ok, deal} =
  ExPipedrive.Deals.create(client, %{
    title: "Jane opportunity",
    person_id: person.id,
    value: 2500.0,
    currency: "USD"
  })
```

### Search (API v2 itemSearch)

```elixir
{:ok, %ExPipedrive.Page{data: results}} =
  ExPipedrive.Search.search_page(client, "acme",
    item_types: ["organization", "person", "deal"],
    limit: 50
  )

# Or scope to one type:
{:ok, page} = ExPipedrive.Search.search_deals(client, "acme")

# Stream across cursor pages:
ExPipedrive.Search.stream(client, "acme", item_types: ["person"])
|> Enum.take(20)
```

Each hit is an `%ExPipedrive.SearchResult{type: "deal", item: %ExPipedrive.Deal{}, ...}`
(persons / organizations / products decode to their structs).

### Custom fields (API v2 Fields)

Pipedrive API v2 nests custom values under `custom_fields` on decoded
`%ExPipedrive.Deal{}`, `%ExPipedrive.Person{}`, and
`%ExPipedrive.Organization{}` structs. The map keys are Pipedrive field hashes
(`field_code`), not the labels shown in the UI. Fetch the matching resource's
field definitions, then resolve hashes and labels with `ExPipedrive.Fields`:

```elixir
{:ok, fields} = ExPipedrive.DealFields.list_page(client)

{:ok, field_code} = ExPipedrive.Fields.key_for(fields, "Customer tier")
{:ok, "Customer tier"} = ExPipedrive.Fields.label_for(fields, field_code)

{:ok, deal} = ExPipedrive.Deals.get(client, deal_id)
tier = deal.custom_fields[field_code]
```

`DealFields`, `PersonFields`, and `OrganizationFields` use Pipedrive's
documented API v2 collection endpoints and return `%ExPipedrive.Page{}`; use
their `stream/2` helpers when definitions span cursor pages. Their legacy
`list_*_fields/2` names remain aliases for `list_page/2`.

### OAuth (multi-tenant)

```elixir
{:ok, token} =
  ExPipedrive.Oauth.exchange_authorization_code(
    auth_code,
    client_id,
    client_secret,
    redirect_uri
  )

# Persist via your TokenStore implementation (Ecto, etc.)
:ok = MyApp.PipedriveTokenStore.put(tenant_id, token)

{:ok, client, token} =
  ExPipedrive.Client.from_token_store(token, client_id, client_secret,
    store: MyApp.PipedriveTokenStore,
    store_id: tenant_id
  )
```

API token auth remains the simple path for single-tenant scripts.

### Public API surface

Prefer **resource modules** (`ExPipedrive.Deals`, `ExPipedrive.Persons`, …) with
v2 names (`get/2`, `create/2`, `list_page/2`, `stream/2`). The root `ExPipedrive`
module is a thin compatibility facade — incomplete by design and not the
blessed path for new code. Legacy twin names (`get_deal/2`, `list_deals/2`,
`create_person/2`, …) are soft-deprecated; see ExDoc `@deprecated` tags.

### Leads and Notes (API v1 shims)

`ExPipedrive.Leads` and `ExPipedrive.Notes` explicitly use API v1 while their
v2 endpoints are unavailable. Prefer `get/2`, `create/2`, and `list/2` (plus
`Leads.update/3`). Older `*_lead` / `add_note` / `list_notes` names remain but
are soft-deprecated.

### Webhook subscriptions (API v1 management)

`ExPipedrive.Webhooks` manages outgoing Pipedrive webhook subscriptions through
the current API v1 management endpoints. This is distinct from
`ExPipedrive.Webhook.*` / `ExPipedrive.Incoming.*`, which receive deliveries in
your app. New subscriptions default to Pipedrive's v2.0 delivery format; pass
`version: "1.0"` only when an existing receiver requires its legacy payload.

```elixir
{:ok, subscription} =
  ExPipedrive.Webhooks.create(client, %{
    subscription_url: "https://example.com/pipedrive/webhooks",
    event_action: "change",
    event_object: "deal",
    name: "Deal changes"
  })

{:ok, subscriptions} = ExPipedrive.Webhooks.list(client)
{:ok, :ok} = ExPipedrive.Webhooks.delete(client, subscription.id)
```

For OAuth apps, request `webhooks:read` to list subscriptions, or
`webhooks:full` to create, list, and delete them. API-token calls use the
permissions of their owning user: regular users can manage their own
subscriptions and only receive events they can see. Use a top-level admin user
(or its `user_id` when creating) for company-wide event coverage. Pipedrive
allows up to 40 webhook subscriptions per user.

### Incoming webhook deliveries (`ex_pipedrive_web`)

`ExPipedrive.Webhook.Event` (core) normalizes Pipedrive webhook deliveries:

- **v1** — `"event"` like `"updated.deal"` / `"added.organization"` with
  `current`/`previous`
- **v2** — `meta.action` + `meta.entity` with `data`/`previous` (name synthesized
  as `"change.lead"`, `"delete.deal"`, …)
- Typed decode for deal, person, organization, activity, lead, note, product,
  pipeline, stage, user, activityType, deal_product, deal_installment, project,
  task, and board; unknown resources stay maps (`event.raw` always retained)

See the matrix on `ExPipedrive.Webhook.Event` / `Event.typed_resources/0`.

The inbound Plug router lives in the optional
[`ex_pipedrive_web`](packages/ex_pipedrive_web) package (Hex-ready, not
published yet). It does not start an OTP application, Registry, or other
fan-out process; the host application owns delivery after the handler callback.

```elixir
{:ex_pipedrive_web, "~> 0.1.0"}
```

Implement the handler behaviour:

```elixir
defmodule MyApp.PipedriveWebhookHandler do
  @behaviour ExPipedrive.Webhook.Handler

  @impl true
  def handle_event(%ExPipedrive.Webhook.Event{action: "updated", resource: "deal"} = event) do
    MyApp.Deals.handle_update(event.current, event.previous, event.diff)
  end

  def handle_event(_event), do: :ok
end
```

Then forward webhook traffic from your Plug or Phoenix router. Basic
authentication is optional; provide `:auth_fn` when Pipedrive is configured
with a username and password.

```elixir
forward "/webhooks", to: ExPipedriveWeb.Incoming.Handler,
  init_opts: [
    handler: MyApp.PipedriveWebhookHandler,
    auth_fn: fn -> [username: "pipedrive", password: System.fetch_env!("PIPEDRIVE_WEBHOOK_SECRET")] end
  ]
```

`ExPipedrive.Incoming.Handler` remains a compatibility alias in
`ex_pipedrive_web`. Existing integrations can continue to use
`on_event: fn {:updated_deal, payload} -> ... end`; new integrations should
use `ExPipedrive.Webhook.Handler`.

### Raw escape hatch

For endpoints without a first-class module, call through auth/JSON/error
normalization:

```elixir
{:ok, body} =
  ExPipedrive.Raw.request(client, :get, "dealFields",
    api_version: :v1,
    query: [limit: 100]
  )

{:ok, body} =
  ExPipedrive.Raw.request(client, :post, "/api/v2/deals",
    body: %{title: "From raw", value: 100, currency: "USD"}
  )
```

### Custom resources

For a typed extension with CRUD/list helpers, implement `ExPipedrive.Resource`
(see its moduledoc example). Prefer `Raw` for one-off calls.

### Retries and telemetry

Clients retry **429** / **502–504** / transport errors by default (honoring
`Retry-After`). They also emit `[:ex_pipedrive, :request, :start|:stop|:exception]`
— no logging is enabled; attach handlers yourself:

```elixir
:telemetry.attach(
  "ex-pipedrive-stop",
  [:ex_pipedrive, :request, :stop],
  fn _event, %{duration: duration}, meta, _config ->
    IO.inspect({duration, meta.rate_limit, meta.retry_count})
  end,
  nil
)

# Opt out or inject middleware:
client =
  ExPipedrive.client(token, domain,
    retry: [max_retries: 5],
    middleware: [{MyApp.TeslaDebug, []}]
  )
```

## Development

### Tooling

- Elixir / OTP: see [`.tool-versions`](https://github.com/blksheep80/ex_pipedrive/blob/main/.tool-versions) (Elixir 1.17.2 / OTP 27)
- Optional Nix shell: [`devenv.nix`](https://github.com/blksheep80/ex_pipedrive/blob/main/devenv.nix) (`direnv allow` then `devenv shell`)
- Issue tracking: [beads](https://github.com/gastownhall/beads) via `bd` (prefix `expd-`)

```bash
mix deps.get
mix test
mix format --check-formatted
mix credo --strict
mix doctor
mix dialyzer
mix docs
```

Dialyzer runs in CI on the primary matrix cell (Elixir 1.17 / OTP 27) with PLT caching. Locally, `mix dialyzer` uses PLTs under `priv/plts/` (gitignored). Stricter flags (`:error_handling`, `:underspecs`) can be added later once the baseline stays green.

Inbound webhook Plug tests live in `packages/ex_pipedrive_web`:

```bash
cd packages/ex_pipedrive_web
mix deps.get
mix test
mix format --check-formatted
mix credo --strict
```

### Hex release

1. Bump `@version` in `mix.exs` and update [CHANGELOG.md](CHANGELOG.md).
2. Tag `vX.Y.Z` and publish a GitHub Release (triggers `.github/workflows/hex-publish.yml`), **or** run `mix hex.publish` locally with `HEX_API_KEY`.
3. Confirm docs on HexDocs after publish.

### Beads

```bash
bd ready          # unblocked work
bd prime          # agent workflow context
bd create "…"     # file new work
```

Fresh clones: `bd bootstrap` after installing `bd` (and `dolt` if using the devenv shell).

## Acknowledgments

Built on [LineDrive](https://github.com/tmecklem/line_drive) by Tim Mecklem. Upstream contributions and design remain gratefully acknowledged.
