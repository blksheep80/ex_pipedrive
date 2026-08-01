defmodule ExPipedrive.Deals do
  @moduledoc """
  Pipedrive deals resource.

  v2-first helpers (`get/2`, `create/2`, `update/3`, `delete/2`, `list_page/2`,
  `stream/2`) talk to `/api/v2/deals` via `ExPipedrive.Resource`. Prefer
  `ExPipedrive.Search.search_deals/3` (or `search_v2/3` here) for v2 itemSearch.
  Legacy `get_deal/2`, `list_deals/2`, and `search_deals/3` remain on API v1 for
  compatibility.
  """

  @behaviour ExPipedrive.Resource

  alias ExPipedrive.Deal
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Resource
  alias ExPipedrive.Response
  alias ExPipedrive.Search
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    title value currency person_id org_id stage_id pipeline_id owner_id
    status visible_to expected_close_date probability lost_reason label_ids
    custom_fields
  )

  @impl true
  def path, do: "deals"

  @impl true
  def decode(data) when is_map(data), do: Deal.new(data)

  @impl true
  def encode(attrs), do: WriteAttrs.take(attrs, @write_fields)

  @impl true
  def list_query_keys do
    [:status, :owner_id, :person_id, :org_id, :pipeline_id, :stage_id]
  end

  # --- API v2 ---

  @doc """
  Fetches a deal by id via `GET /api/v2/deals/:id`.
  """
  def get(%Client{} = client, deal_id) do
    Resource.get(__MODULE__, client, deal_id)
  end

  @doc """
  Creates a deal via `POST /api/v2/deals`.

  Accepts a map (preferred) or `%Deal{}`. Returns `{:ok, %Deal{}}`.
  """
  def create(%Client{} = client, attrs) do
    Resource.create(__MODULE__, client, attrs, success_statuses: [201])
  end

  @doc """
  Updates a deal via `PATCH /api/v2/deals/:id`.
  """
  def update(%Client{} = client, deal_id, attrs) do
    Resource.update(__MODULE__, client, deal_id, attrs)
  end

  @doc """
  Deletes a deal via `DELETE /api/v2/deals/:id`.
  """
  def delete(%Client{} = client, deal_id) do
    Resource.delete(__MODULE__, client, deal_id)
  end

  @doc """
  Lists one page of deals via API v2 cursor pagination.

  Options: `:cursor`, `:limit` (clamped to 500), `:status`, `:owner_id`,
  `:person_id`, `:org_id`, `:pipeline_id`, `:stage_id`.
  """
  def list_page(%Client{} = client, opts \\ []) do
    list_deals_page(client, opts)
  end

  @doc """
  Lazily streams deals across all v2 cursor pages until `next_cursor` is nil.

  ## Example

      client
      |> ExPipedrive.Deals.stream(status: "open", limit: 500)
      |> Enum.to_list()
  """
  def stream(%Client{} = client, opts \\ []) do
    stream_deals(client, opts)
  end

  def list_deals_page(%Client{} = client, opts \\ []) do
    Resource.list_page(__MODULE__, client, opts)
  end

  def stream_deals(%Client{} = client, opts \\ []) do
    Resource.stream(__MODULE__, client, opts)
  end

  # --- API v1 (legacy) ---

  @doc """
  Soft-deprecated: prefer `get/2` (API v2).
  """
  def get_deal(%Client{} = client, deal_id) do
    client
    |> Request.get("deals/:id", api_version: :v1, opts: [path_params: [id: deal_id]])
    |> Response.map([200], fn %{body: %{"data" => deal_data}} ->
      Deal.new(deal_data)
    end)
  end

  @doc """
  Soft-deprecated: prefer `list_page/2` or `stream/2` (API v2).
  """
  def list_deals(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)
    status = Keyword.get(opts, :status, "all_not_deleted")

    client
    |> Request.get("deals",
      api_version: :v1,
      query: [start: start, limit: limit, status: status]
    )
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} ->
        PagedResult.new(Enum.map(data, &Deal.new/1), body)
    end)
  end

  @doc """
  Soft-deprecated: prefer `ExPipedrive.Search.search_deals/3` or `search_v2/3`.
  """
  def search_deals(%Client{} = client, term, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)
    status = Keyword.get(opts, :status, "open")

    client
    |> Request.get("deals/search",
      api_version: :v1,
      query: [term: term, start: start, limit: limit, status: status]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      data
      |> Map.get("items")
      |> Enum.map(fn item_container -> Deal.new(Map.get(item_container, "item")) end)
    end)
  end

  @doc """
  Searches deals via API v2 itemSearch. See `ExPipedrive.Search.search_deals/3`.
  """
  def search_v2(%Client{} = client, term, opts \\ []) do
    Search.search_deals(client, term, opts)
  end
end
