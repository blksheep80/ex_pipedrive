defmodule ExPipedriveOban.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/blksheep80/ex_pipedrive"

  def project do
    [
      app: :ex_pipedrive_oban,
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

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      ex_pipedrive_dep(),
      {:oban, "~> 2.17"}
    ] ++ path_dev_pins()
  end

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
        {:ex_pipedrive, "~> 0.1"}

      true ->
        root = Path.expand("../..", __DIR__)
        mix = Path.join(root, "mix.exs")

        if File.exists?(mix) and File.read!(mix) =~ ~r/app:\s*:ex_pipedrive/ do
          {:ex_pipedrive, path: root, override: true}
        else
          {:ex_pipedrive, "~> 0.1"}
        end
    end
  end

  defp description do
    """
    Optional Oban workers for cursor-aware Pipedrive sync with rate-limit
    snooze. Depends on ex_pipedrive; the host app owns Oban, Ecto, and TokenStore.
    """
  end

  defp package do
    [
      name: "ex_pipedrive_oban",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/packages/ex_pipedrive_oban/CHANGELOG.md",
        "HexDocs" => "https://hexdocs.pm/ex_pipedrive_oban",
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
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"]
    ]
  end
end
