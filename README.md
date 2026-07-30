# ExPipedrive

Elixir client for the [Pipedrive](https://www.pipedrive.com) CRM API.

This repository is a fork of [tmecklem/line_drive](https://github.com/tmecklem/line_drive), rebranded as **ExPipedrive** (`ex_pipedrive` / `ExPipedrive.*`) and evolving toward a **v2-first** SDK.

> **Status:** early foundation — rebrand complete; v2 client work is tracked in [HANDOFF.md](HANDOFF.md) and the [issue tracker](https://github.com/blksheep80/ex_pipedrive/issues).

## Goals

- Pipedrive API v2 as the default, with explicit v1 fallback where needed
- API token **and** OAuth (pluggable TokenStore; no Ecto in core)
- Lean core library; optional packages later for webhooks, Oban sync, Phoenix helpers
- MVP proof flows: stream open deals via cursor pagination; create person + deal

## Installation

```elixir
def deps do
  [
    {:ex_pipedrive, "~> 0.1.0"}
  ]
end
```

Until the package is on Hex, you can depend on GitHub:

```elixir
def deps do
  [
    {:ex_pipedrive, github: "blksheep80/ex_pipedrive"}
  ]
end
```

Core runtime deps are Tesla, Jason, and TypedStruct. **Plug is optional** — add it only if you mount `ExPipedrive.Incoming.Handler` for webhooks:

```elixir
{:plug, ">= 1.16.0"}
```

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

API token auth remains the simple path for single-tenant scripts. Legacy v1
list/search helpers remain available (e.g. `ExPipedrive.list_deals/2`).

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

## Development

### Tooling

- Elixir / OTP: see [`.tool-versions`](.tool-versions) (Elixir 1.17.2 / OTP 27)
- Optional Nix shell: [`devenv.nix`](devenv.nix) (`direnv allow` then `devenv shell`)
- Issue tracking: [beads](https://github.com/gastownhall/beads) via `bd` (prefix `expd-`)

```bash
mix deps.get
mix test
mix format --check-formatted
mix credo --strict
mix doctor
mix docs
```

Dialyzer (`mix dialyzer`) is optional locally before releases; not required in CI yet (see [AUDIT.md](AUDIT.md) tooling decisions).

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
