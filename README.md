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

Not yet published to Hex. Until the first release, depend on GitHub:

```elixir
def deps do
  [
    {:ex_pipedrive, github: "blksheep80/ex_pipedrive"}
  ]
end
```

After the package lands on Hex:

```elixir
def deps do
  [
    {:ex_pipedrive, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
client = ExPipedrive.client("your-api-token", "your-company.pipedrive.com")

{:ok, deals} = ExPipedrive.list_deals(client, status: "open")
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
```

### Beads

```bash
bd ready          # unblocked work
bd prime          # agent workflow context
bd create "…"     # file new work
```

Fresh clones: `bd bootstrap` after installing `bd` (and `dolt` if using the devenv shell).

## Acknowledgments

Built on [LineDrive](https://github.com/tmecklem/line_drive) by Tim Mecklem. Upstream contributions and design remain gratefully acknowledged.
