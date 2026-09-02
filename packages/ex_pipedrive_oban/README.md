# ExPipedriveOban

Optional [Oban](https://hex.pm/packages/oban) workers for **cursor-aware Pipedrive
sync**. Core [`ex_pipedrive`](https://hex.pm/packages/ex_pipedrive) stays free of
Oban; this package owns the worker, unique-job keys, and rate-limit snooze.

The host application already runs Oban (and Ecto). This package does not start
an Oban instance or a repo.

## Installation

```elixir
def deps do
  [
    {:ex_pipedrive, "~> 0.2.0"},
    {:ex_pipedrive_oban, "~> 0.1.0"}
  ]
end
```

Add a Pipedrive queue to your existing Oban config:

```elixir
config :my_app, Oban,
  repo: MyApp.Repo,
  queues: [pipedrive: 5]
```

## Source callback

Implement `ExPipedriveOban.Source` to build a client and persist each page:

```elixir
defmodule MyApp.PipedriveSync do
  @behaviour ExPipedriveOban.Source

  @impl true
  def client(%{"tenant_id" => tenant_id}) do
    ExPipedrive.Client.from_token_store(MyApp.PipedriveTokenStore, tenant_id)
  end

  @impl true
  def handle_page("deals", deals, %{"tenant_id" => tenant_id}) do
    MyApp.Deals.upsert_many(tenant_id, deals)
    :ok
  end

  def handle_page(_resource, _rows, _args), do: :ok
end
```

Prefer `retry: false` on the Tesla client so Oban snooze owns 429 backoff
(core retries 429 a few times first if you leave the default on).

## Enqueue a deals sync

```elixir
%{
  "source" => "Elixir.MyApp.PipedriveSync",
  "tenant_id" => "acme",
  "resource" => "deals",
  "list_opts" => %{"status" => "open"}
}
|> ExPipedriveOban.SyncWorker.new()
|> Oban.insert()
```

`ExPipedriveOban.Workers.SyncDeals.enqueue/3` is a thin helper for that map.

Kickoff jobs are unique per `tenant_id` + `resource` so two full syncs do not
overlap. Continuation pages insert with `unique: false`.

On `{:error, %ExPipedrive.Error{kind: :rate_limited}}`, the worker
`{:snooze, seconds}` using `Retry-After` / `x-ratelimit-reset` when present
(default 15s).

Supported `resource` values: `deals`, `persons`, `organizations` (each via
`list_page/2`).

## Version coupling

| This package | Core |
|---|---|
| `0.1.x` | `ex_pipedrive ~> 0.2` |

Inside this git repo Mix uses a **path** dependency on core. Hex consumers get
`{:ex_pipedrive, "~> 0.2"}`.

```bash
cd packages/ex_pipedrive_oban
HEX_PUBLISH=1 mix hex.publish
```

Not published to Hex yet — layout and metadata are publish-ready.

## Development

```bash
mix deps.get
mix test
mix format --check-formatted
mix credo --strict
```
