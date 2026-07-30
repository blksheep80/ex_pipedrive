defmodule ExPipedrive.Leads do
  @moduledoc """
  API v1 shim for Pipedrive leads.

  All functions in this module explicitly route to `/api/v1/leads`. Prefer the
  `get/2`, `create/2`, `update/3`, and `list/2` aliases for new code; the original
  `*_lead` names remain supported for compatibility. A v2 Leads resource can
  replace this shim without changing callers that use those aliases.
  """

  alias ExPipedrive.Lead
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    title owner_id label_ids person_id organization_id source_name origin channel
    channel_id value expected_close_date visible_to
  )

  @doc """
  Creates a lead through `POST /api/v1/leads`.

  Accepts a map (preferred) or `%Lead{}` and returns `{:ok, %Lead{}}`.
  """
  def create(%Client{} = client, attrs), do: create_lead(client, attrs)

  @doc """
  Creates a lead through `POST /api/v1/leads`.
  """
  def create_lead(%Client{} = client, attrs) when is_map(attrs) do
    client
    |> Request.post("leads", WriteAttrs.take(attrs, @write_fields), api_version: :v1)
    |> Response.map([201], fn %{body: %{"data" => lead_data}} ->
      Lead.new(lead_data)
    end)
  end

  @doc """
  Fetches a lead by id through `GET /api/v1/leads/:id`.
  """
  def get(%Client{} = client, lead_id), do: get_lead(client, lead_id)

  @doc """
  Fetches a lead by id through `GET /api/v1/leads/:id`.
  """
  def get_lead(%Client{} = client, lead_id) do
    client
    |> Request.get("leads/:id", api_version: :v1, opts: [path_params: [id: lead_id]])
    |> Response.map([200], fn %{body: %{"data" => lead_data}} ->
      Lead.new(lead_data)
    end)
  end

  @doc """
  Updates a lead through `PATCH /api/v1/leads/:id`.

  Accepts a map (preferred) or `%Lead{}` and returns `{:ok, %Lead{}}`.
  """
  def update(%Client{} = client, lead_id, attrs), do: update_lead(client, lead_id, attrs)

  @doc """
  Updates a lead through `PATCH /api/v1/leads/:id`.
  """
  def update_lead(%Client{} = client, lead_id, attrs) when is_map(attrs) do
    client
    |> Request.patch(
      "leads/:id",
      WriteAttrs.take(attrs, @write_fields),
      api_version: :v1,
      opts: [path_params: [id: lead_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => lead_data}} ->
      Lead.new(lead_data)
    end)
  end

  @doc """
  Lists leads through `GET /api/v1/leads`.

  Supports `:start`, `:limit`, `:owner_id`, `:person_id`, `:organization_id`,
  `:filter_id`, and `:sort`.
  """
  def list(%Client{} = client, opts \\ []), do: list_leads(client, opts)

  @doc """
  Lists leads through `GET /api/v1/leads`.
  """
  def list_leads(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    query_params =
      [start: start, limit: limit]
      |> maybe_add_filter(opts, :owner_id)
      |> maybe_add_filter(opts, :person_id)
      |> maybe_add_filter(opts, :organization_id)
      |> maybe_add_filter(opts, :filter_id)
      |> maybe_add_filter(opts, :sort)

    client
    |> Request.get("leads", api_version: :v1, query: query_params)
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} ->
        PagedResult.new(Enum.map(data, &Lead.new/1), body)
    end)
  end

  def search_leads(%Client{} = client, term, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("leads/search",
      api_version: :v1,
      query: [term: term, start: start, limit: limit]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      data
      |> Map.get("items")
      |> Enum.map(fn item_container -> Lead.new(Map.get(item_container, "item")) end)
    end)
  end

  defp maybe_add_filter(query_params, opts, key) do
    case Keyword.get(opts, key) do
      nil -> query_params
      value -> Keyword.put(query_params, key, value)
    end
  end
end
