defmodule LineDrive.MixProject do
  use Mix.Project

  def project do
    [
      app: :line_drive,
      description: description(),
      deps: deps(),
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      package: package(),
      start_permanent: Mix.env() == :prod,
      version: "0.29.0"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {LineDrive.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:jason, "~> 1.3"},
      {:plug, ">= 1.16.0"},
      {:plug_cowboy, "~> 2.7", only: [:test]},
      {:tesla, "~> 1.12"},
      {:timex, "~> 3.7"},
      {:typed_struct, "~> 0.3.0"}
    ]
  end

  defp description do
    ~s"""
    LineDrive is a client package for communicating with Pipedrive (pipedrive.com)
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/tmecklem/line_drive"}
    ]
  end
end
