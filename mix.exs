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

  # Runtime core: jason, tesla, telemetry, typed_struct.
  # plug is optional — required only for ExPipedrive.Incoming.Handler (webhooks).
  # plug_cowboy is test-only (fake Pipedrive server). Timex removed (#27).
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:doctor, "~> 0.22", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:jason, "~> 1.3"},
      {:plug, ">= 1.16.0", optional: true},
      {:plug_cowboy, "~> 2.7", only: [:test]},
      {:telemetry, "~> 1.0"},
      {:tesla, "~> 1.12"},
      {:typed_struct, "~> 0.3.0"}
    ]
  end

  defp description do
    """
    Elixir client for the Pipedrive CRM API. v2-first (Deals, Persons, Orgs,
    Activities, Pipelines, Stages, Products, Search, Fields), with OAuth
    TokenStore, retries/telemetry, Raw escape hatch, and webhook helpers.
    Forked from LineDrive.
    """
  end

  defp package do
    [
      name: "ex_pipedrive",
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "HexDocs" => "https://hexdocs.pm/ex_pipedrive",
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
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"],
      groups_for_modules: [
        HTTP: [
          ExPipedrive,
          ExPipedrive.Client,
          ExPipedrive.Request,
          ExPipedrive.Raw,
          ExPipedrive.Resource,
          ExPipedrive.Response,
          ExPipedrive.Error,
          ExPipedrive.RateLimit,
          ExPipedrive.Middleware.Retry,
          ExPipedrive.Middleware.Telemetry,
          ExPipedrive.Page,
          ExPipedrive.Cursor,
          ExPipedrive.PagedResult,
          ExPipedrive.WriteAttrs
        ],
        "CRM resources": [
          ExPipedrive.Deals,
          ExPipedrive.Persons,
          ExPipedrive.Organizations,
          ExPipedrive.Activities,
          ExPipedrive.Pipelines,
          ExPipedrive.Stages,
          ExPipedrive.Products,
          ExPipedrive.DealProducts,
          ExPipedrive.Leads,
          ExPipedrive.Notes,
          ExPipedrive.Filters,
          ExPipedrive.Goals,
          ExPipedrive.Files,
          ExPipedrive.CallLogs,
          ExPipedrive.ActivityTypes,
          ExPipedrive.Users,
          ExPipedrive.Currencies,
          ExPipedrive.Recents,
          ExPipedrive.Roles,
          ExPipedrive.PermissionSets,
          ExPipedrive.Teams,
          ExPipedrive.Deal,
          ExPipedrive.Person,
          ExPipedrive.Organization,
          ExPipedrive.Activity,
          ExPipedrive.Pipeline,
          ExPipedrive.Stage,
          ExPipedrive.Product,
          ExPipedrive.DealProduct,
          ExPipedrive.Lead,
          ExPipedrive.Note,
          ExPipedrive.Filter,
          ExPipedrive.Goal,
          ExPipedrive.File,
          ExPipedrive.CallLog,
          ExPipedrive.Currency,
          ExPipedrive.Recent,
          ExPipedrive.Role,
          ExPipedrive.RoleAssignment,
          ExPipedrive.PermissionSet,
          ExPipedrive.Team
        ],
        Fields: [
          ExPipedrive.Fields,
          ExPipedrive.DealFields,
          ExPipedrive.PersonFields,
          ExPipedrive.OrganizationFields,
          ExPipedrive.ActivityFields,
          ExPipedrive.ProductFields,
          ExPipedrive.Field,
          ExPipedrive.FieldOption
        ],
        Search: [
          ExPipedrive.Search,
          ExPipedrive.SearchResult
        ],
        Collaboration: [
          ExPipedrive.Followers,
          ExPipedrive.Follower,
          ExPipedrive.DealParticipants,
          ExPipedrive.DealParticipant,
          ExPipedrive.OrganizationRelationships,
          ExPipedrive.OrganizationRelationship
        ],
        Mailbox: [
          ExPipedrive.Mailbox,
          ExPipedrive.MailThread,
          ExPipedrive.MailMessage,
          ExPipedrive.MailMessageParty
        ],
        OAuth: [
          ExPipedrive.Oauth,
          ExPipedrive.Oauth.Token,
          ExPipedrive.Oauth.TokenStore,
          ExPipedrive.Oauth.TokenStore.Memory
        ],
        Webhooks: [
          ExPipedrive.Webhooks,
          ExPipedrive.Webhooks.Subscription,
          ExPipedrive.Webhook.Event,
          ExPipedrive.Webhook.Handler,
          ExPipedrive.Incoming.Handler
        ]
      ]
    ]
  end
end
