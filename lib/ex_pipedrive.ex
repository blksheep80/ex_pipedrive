defmodule ExPipedrive do
  @moduledoc """
  Convenience entrypoint for ExPipedrive.

  ## Blessed path (prefer this)

  Call resource modules directly — they are the supported public surface:

      client = ExPipedrive.client(token, "company.pipedrive.com")
      {:ok, deal} = ExPipedrive.Deals.get(client, deal_id)
      ExPipedrive.Deals.stream(client, status: "open") |> Enum.to_list()
      {:ok, page} = ExPipedrive.Search.search_deals(client, "acme")

  Naming conventions:

  - **API v2:** `get/2`, `create/2`, `update/3`, `delete/2`, `list_page/2`, `stream/2`
  - **API v1 offset lists:** `list/2` → `{:ok, %ExPipedrive.PagedResult{}}`
  - **Escape hatch:** `ExPipedrive.Raw` / `ExPipedrive.Resource`

  This root module keeps a **compatibility facade** of convenience wrappers
  (LineDrive-era names and a subset of v2 list/stream helpers). It is
  intentionally incomplete — newer modules (Projects, Files, Filters, …) are not
  mirrored here. Prefer the `ExPipedrive.*` resource modules for new code.

  Legacy twin functions on resource modules (e.g. `Deals.get_deal/2`) are soft-
  deprecated; they remain available but document a migration path to the v2 names.
  """

  alias ExPipedrive.Client

  # --- Client ---

  @doc """
  Builds a Tesla client authenticated with a Pipedrive API token.

  `api_domain` may be a full base URL or a host (e.g. `company.pipedrive.com`).
  Defaults to `x-api-token` header auth; see `ExPipedrive.Client` for options
  and `ExPipedrive.Request` for versioned routing.
  """
  def client(api_token, api_domain, opts \\ []) do
    Client.new(api_token, api_domain, opts)
  end

  @doc """
  Builds a Tesla client by refreshing an OAuth access token once.
  """
  defdelegate build_client(refresh_token, client_id, client_secret, api_domain),
    to: Client,
    as: :from_oauth

  # --- Recommended facade mirrors (API v2 list/stream where available) ---

  defdelegate list_activities_page(client, opts \\ []), to: ExPipedrive.Activities
  defdelegate stream_activities(client, opts \\ []), to: ExPipedrive.Activities
  defdelegate list_deals_page(client, opts \\ []), to: ExPipedrive.Deals
  defdelegate stream_deals(client, opts \\ []), to: ExPipedrive.Deals
  defdelegate list_organizations_page(client, opts \\ []), to: ExPipedrive.Organizations
  defdelegate stream_organizations(client, opts \\ []), to: ExPipedrive.Organizations
  defdelegate list_persons_page(client, opts \\ []), to: ExPipedrive.Persons
  defdelegate stream_persons(client, opts \\ []), to: ExPipedrive.Persons
  defdelegate list_products_page(client, opts \\ []), to: ExPipedrive.Products
  defdelegate stream_products(client, opts \\ []), to: ExPipedrive.Products
  defdelegate search_page(client, term, opts \\ []), to: ExPipedrive.Search
  defdelegate stream_search(client, term, opts \\ []), to: ExPipedrive.Search, as: :stream
  defdelegate list_users(client, opts \\ []), to: ExPipedrive.Users, as: :list
  defdelegate get_user(client, user_id), to: ExPipedrive.Users, as: :get
  defdelegate me(client), to: ExPipedrive.Users
  defdelegate find_users_by_name(client, term, opts \\ []), to: ExPipedrive.Users
  defdelegate list_activity_types(client), to: ExPipedrive.ActivityTypes
  defdelegate list_deal_fields(client, opts), to: ExPipedrive.DealFields
  defdelegate list_person_fields(client, opts), to: ExPipedrive.PersonFields
  defdelegate list_organization_fields(client, opts), to: ExPipedrive.OrganizationFields

  # Leads / Notes v1 shims — prefer module `get`/`create`/`list` aliases
  defdelegate list_leads(client, opts \\ []), to: ExPipedrive.Leads, as: :list
  defdelegate list_notes(client, opts \\ []), to: ExPipedrive.Notes, as: :list

  # --- Legacy facade names (soft-deprecated; prefer resource modules) ---

  @deprecated "Use ExPipedrive.Activities.create/2"
  def add_activity(client, activity), do: ExPipedrive.Activities.add_activity(client, activity)

  @deprecated "Use ExPipedrive.Notes.create/2"
  def add_note(client, note), do: ExPipedrive.Notes.add_note(client, note)

  @deprecated "Use ExPipedrive.Leads.create/2"
  def create_lead(client, lead), do: ExPipedrive.Leads.create_lead(client, lead)

  @deprecated "Use ExPipedrive.Organizations.create/2"
  def create_organization(client, org),
    do: ExPipedrive.Organizations.create_organization(client, org)

  @deprecated "Use ExPipedrive.Persons.create/2"
  def create_person(client, person), do: ExPipedrive.Persons.create_person(client, person)

  @deprecated "Use ExPipedrive.Notes.list/2 with org_id:"
  def get_all_org_notes(client, org_id, opts \\ []),
    do: ExPipedrive.Notes.get_all_org_notes(client, org_id, opts)

  @deprecated "Use ExPipedrive.Deals.get/2"
  def get_deal(client, deal_id), do: ExPipedrive.Deals.get_deal(client, deal_id)

  @deprecated "Use ExPipedrive.Leads.get/2"
  def get_lead(client, lead_id), do: ExPipedrive.Leads.get_lead(client, lead_id)

  @deprecated "Use ExPipedrive.Organizations.get/2"
  def get_organization(client, org_id),
    do: ExPipedrive.Organizations.get_organization(client, org_id)

  @deprecated "Use ExPipedrive.Persons.get/2"
  def get_person(client, person_id), do: ExPipedrive.Persons.get_person(client, person_id)

  @deprecated "Use ExPipedrive.Activities.list_page/2 or stream/2"
  def list_activities(client, opts \\ []),
    do: ExPipedrive.Activities.list_activities(client, opts)

  @deprecated "Use ExPipedrive.Deals.list_page/2 or stream/2"
  def list_deals(client, opts), do: ExPipedrive.Deals.list_deals(client, opts)

  @deprecated "Use ExPipedrive.Organizations.list_page/2 or stream/2"
  def list_organizations(client, opts),
    do: ExPipedrive.Organizations.list_organizations(client, opts)

  @deprecated "Use ExPipedrive.Activities.list_page/2 with owner_id:"
  def list_own_activities(client, opts \\ []),
    do: ExPipedrive.Activities.list_own_activities(client, opts)

  @deprecated "Use ExPipedrive.Persons.list_page/2 or stream/2"
  def list_persons(client, opts), do: ExPipedrive.Persons.list_persons(client, opts)

  @deprecated "Use ExPipedrive.Pipelines.list_page/2 or stream/2"
  def list_pipelines(client), do: ExPipedrive.Pipelines.list_pipelines(client)

  @deprecated "Use ExPipedrive.Deals.list_page/2 with pipeline_id:"
  def list_pipeline_deals(client, pipeline_id),
    do: ExPipedrive.Pipelines.list_pipeline_deals(client, pipeline_id)

  @deprecated "Use ExPipedrive.Search.search_deals/3"
  def search_deals(client, term, opts),
    do: ExPipedrive.Deals.search_deals(client, term, opts)

  @deprecated "Use ExPipedrive.Leads.list/2 where possible"
  def search_leads(client, term, opts),
    do: ExPipedrive.Leads.search_leads(client, term, opts)

  @deprecated "Use ExPipedrive.Search.search_organizations/3"
  def search_organizations(client, term, opts),
    do: ExPipedrive.Organizations.search_organizations(client, term, opts)

  @deprecated "Use ExPipedrive.Search.search_persons/3"
  def search_persons(client, term, opts),
    do: ExPipedrive.Persons.search_persons(client, term, opts)

  @deprecated "Use ExPipedrive.Organizations.update/3"
  def update_organization(client, org_id, data),
    do: ExPipedrive.Organizations.update_organization(client, org_id, data)
end
