# ExPipedriveWeb

Optional Plug helpers for **incoming Pipedrive webhooks**. Payload
normalization (`ExPipedrive.Webhook.Event`) and the handler behaviour live in
core [`ex_pipedrive`](https://hex.pm/packages/ex_pipedrive). This package owns
the Plug router only.

Phoenix is not a dependency: a Phoenix router can `forward` to the Plug the
same way a raw Plug router can.

## Installation

```elixir
def deps do
  [
    {:ex_pipedrive, "~> 0.2.0"},
    {:ex_pipedrive_web, "~> 0.1.0"}
  ]
end
```

Core stays usable without this package (API client, OAuth TokenStore, webhook
*subscription* CRUD). Add `ex_pipedrive_web` only if you mount an inbound
webhook endpoint.

## Usage

Implement the core behaviour:

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

Forward traffic from Plug or Phoenix. Basic auth is optional (`:auth_fn`).

```elixir
forward "/webhooks", to: ExPipedriveWeb.Incoming.Handler,
  init_opts: [
    handler: MyApp.PipedriveWebhookHandler,
    auth_fn: fn ->
      [username: "pipedrive", password: System.fetch_env!("PIPEDRIVE_WEBHOOK_SECRET")]
    end
  ]
```

Existing mounts that use `ExPipedrive.Incoming.Handler` still work as
compatibility aliases once this package is in `deps`.

Legacy `on_event: fn {:updated_deal, payload} -> ... end` remains supported
for deal/person updates; new code should use `ExPipedrive.Webhook.Handler`.

The host application owns fan-out (Oban, PubSub, Registry). This package does
not start an OTP application or process mailbox.

## Version coupling

| This package | Core |
|---|---|
| `0.1.x` | `ex_pipedrive ~> 0.2` |

Inside this git repo, Mix uses a **path** dependency on core so CI tracks
unreleased core changes. Hex consumers get `{:ex_pipedrive, "~> 0.2"}`.

To publish this package:

```bash
cd packages/ex_pipedrive_web
HEX_PUBLISH=1 mix hex.publish
```

`HEX_PUBLISH=1` swaps the path dep for the Hex requirement (Hex rejects path
deps). Publish core first when bumping a required core version.

Not published to Hex yet — layout and metadata are publish-ready.

## Development

From this directory:

```bash
mix deps.get
mix test
mix format --check-formatted
mix credo --strict
```
