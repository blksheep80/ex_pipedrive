defmodule ExPipedriveWeb.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/blksheep80/ex_pipedrive"

  def project do
    [
      app: :ex_pipedrive_web,
      version: @version,
      elixir: "~> 1.17",
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      source_url: @source_url,
      homepage_url: @source_url,
      elixirc_options: [warnings_as_errors: true],
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Runtime: plug + jason. Core is a path dep inside this repo and a Hex dep
  # for published packages. See README "Version coupling".
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      ex_pipedrive_dep(),
      {:jason, "~> 1.3"},
      {:plug, ">= 1.16.0"}
    ] ++ path_dev_pins()
  end

  # When developing against the path dep, pin Tesla to core's 1.12.x line so
  # Mix does not resolve Tesla 1.21 (soft-deprecation noise). Hex publishes
  # without this extra pin (`HEX_PUBLISH=1`).
  defp path_dev_pins do
    if System.get_env("HEX_PUBLISH") in ~w(1 true) do
      []
    else
      [{:tesla, "~> 1.12.0"}]
    end
  end

  defp ex_pipedrive_dep do
    cond do
      System.get_env("HEX_PUBLISH") in ~w(1 true) ->
        {:ex_pipedrive, "~> 0.2"}

      true ->
        root = Path.expand("../..", __DIR__)
        mix = Path.join(root, "mix.exs")

        if File.exists?(mix) and File.read!(mix) =~ ~r/app:\s*:ex_pipedrive/ do
          {:ex_pipedrive, path: root, override: true}
        else
          {:ex_pipedrive, "~> 0.2"}
        end
    end
  end

  defp description do
    """
    Optional Plug helpers for incoming Pipedrive webhooks. Depends on
    ex_pipedrive for Event structs; the host app owns Phoenix routing and fan-out.
    """
  end

  defp package do
    [
      name: "ex_pipedrive_web",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/packages/ex_pipedrive_web/CHANGELOG.md",
        "HexDocs" => "https://hexdocs.pm/ex_pipedrive_web",
        "Core" => "https://hex.pm/packages/ex_pipedrive"
      },
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE.md CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"],
      groups_for_modules: [
        Incoming: [
          ExPipedriveWeb.Incoming.Handler,
          ExPipedriveWeb.Incoming.DealHandler,
          ExPipedriveWeb.Incoming.PersonHandler
        ]
      ]
    ]
  end
end
