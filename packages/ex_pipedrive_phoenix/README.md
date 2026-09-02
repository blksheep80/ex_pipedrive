# ExPipedrivePhoenix

Optional [Phoenix](https://hex.pm/packages/phoenix) helpers for Pipedrive
**marketplace OAuth install** (authorize redirect + callback). Token exchange
and `TokenStore` live in core [`ex_pipedrive`](https://hex.pm/packages/ex_pipedrive).

This package is **independent of Überauth**. If you already use
[`ueberauth_pipedrive`](https://hex.pm/packages/ueberauth_pipedrive), keep it;
otherwise this is the first-party install path that stores
`ExPipedrive.Oauth.Token` via your `TokenStore`.

Core OAuth remains usable without Phoenix.

## Installation

```elixir
def deps do
  [
    {:ex_pipedrive, "~> 0.2.0"},
    {:ex_pipedrive_phoenix, "~> 0.1.0"}
  ]
end
```

## Minimal install flow

```elixir
defmodule MyAppWeb.PipedriveController do
  use MyAppWeb, :controller
  use ExPipedrivePhoenix.Install,
    token_store: MyApp.PipedriveTokenStore,
    tenant_assign: :current_account_id,
    success_to: "/settings/pipedrive",
    error_to: "/settings/pipedrive?error=1"
end
```

```elixir
# router.ex
scope "/pipedrive", MyAppWeb do
  pipe_through [:browser, :require_authenticated_user]
  get "/install", PipedriveController, :authorize
  get "/callback", PipedriveController, :callback
end
```

```elixir
# config/runtime.exs
config :my_app, ExPipedrivePhoenix,
  client_id: System.fetch_env!("PIPEDRIVE_CLIENT_ID"),
  client_secret: System.fetch_env!("PIPEDRIVE_CLIENT_SECRET"),
  redirect_uri: "https://app.example.com/pipedrive/callback"
```

`authorize/2` stores a CSRF `state` in the session and redirects to Pipedrive.
`callback/2` verifies `state`, exchanges the code, and `TokenStore.put/2`s the
token for `conn.assigns[tenant_assign]` (or a literal `:tenant_id` option).

Pass `:otp_app` (default `:ex_pipedrive_phoenix`) if config lives under another
app key.

## Version coupling

| This package | Core |
|---|---|
| `0.1.x` | `ex_pipedrive ~> 0.2` |

```bash
cd packages/ex_pipedrive_phoenix
HEX_PUBLISH=1 mix hex.publish
```

Hex: [`ex_pipedrive_phoenix` 0.1.0](https://hex.pm/packages/ex_pipedrive_phoenix).

## Development

```bash
mix deps.get
mix test
mix format --check-formatted
mix credo --strict
```
