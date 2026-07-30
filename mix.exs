defmodule ExPipedrive.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/blksheep80/ex_pipedrive"

  def project do
    [
      app: :ex_pipedrive,
      version: @version,
      elixir: "~> 1.17",
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      source_url: @source_url,
      homepage_url: @source_url,
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Runtime core: jason, tesla, typed_struct.
  # plug is optional — required only for ExPipedrive.Incoming.Handler (webhooks).
  # plug_cowboy is test-only (fake Pipedrive server). Timex removed (#27).
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:jason, "~> 1.3"},
      {:plug, ">= 1.16.0", optional: true},
      {:plug_cowboy, "~> 2.7", only: [:test]},
      {:tesla, "~> 1.12"},
      {:typed_struct, "~> 0.3.0"}
    ]
  end

  defp description do
    """
    Elixir client for the Pipedrive CRM API (v2-first), forked from LineDrive.
    """
  end

  defp package do
    [
      name: "ex_pipedrive",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "Upstream (LineDrive)" => "https://github.com/tmecklem/line_drive"
      },
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE.md CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md", "HANDOFF.md", "AUDIT.md"],
      groups_for_modules: [
        HTTP: [
          ExPipedrive,
          ExPipedrive.Client,
          ExPipedrive.Request,
          ExPipedrive.Response,
          ExPipedrive.Error,
          ExPipedrive.Page,
          ExPipedrive.Cursor,
          ExPipedrive.PagedResult
        ],
        "Deals & Persons": [
          ExPipedrive.Deals,
          ExPipedrive.Persons,
          ExPipedrive.Deal,
          ExPipedrive.Person
        ],
        OAuth: [
          ExPipedrive.Oauth,
          ExPipedrive.Oauth.Token,
          ExPipedrive.Oauth.TokenStore,
          ExPipedrive.Oauth.TokenStore.Memory
        ]
      ]
    ]
  end
end
