defmodule ExPipedrive.Deals do
  @moduledoc """
  Pipedrive deals resource.

  v2-first helpers (`get/2`, `create/2`, `update/3`, `delete/2`, `list_page/2`,
  `stream/2`) talk to `/api/v2/deals`. Prefer `ExPipedrive.Search.search_deals/3`
  (or `search_v2/3` here) for v2 itemSearch. Legacy `get_deal/2`, `list_deals/2`,
  and `search_deals/3` remain on API v1 for compatibility.
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.Deal
  alias ExPipedrive.Page
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.Search
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    title value currency person_id org_id stage_id pipeline_id owner_id
    status visible_to expected_close_date probability lost_reason label_ids
    custom_fields
  )

  # --- API v2 ---

  @doc """
  Fetches a deal by id via `GET /api/v2/deals/:id`.
  """
  def get(%Client{} = client, deal_id) do
    client
    |> Request.get("deals/:id", opts: [path_params: [id: deal_id]])
    |> Response.map([200], fn %{body: %{"data" => deal_data}} ->
      Deal.new(deal_data)
    end)
  end

  @doc """
  Creates a deal via `POST /api/v2/deals`.

  Accepts a map (preferred) or `%Deal{}`. Returns `{:ok, %Deal{}}`.
  """
  def create(%Client{} = client, attrs) do
    body = WriteAttrs.take(attrs, @write_fields)

    client
    |> Request.post("deals", body)
    |> Response.map([201], fn %{body: %{"data" => deal_data}} ->
      Deal.new(deal_data)
    end)
  end

  @doc """
  Updates a deal via `PATCH /api/v2/deals/:id`.
  """
  def update(%Client{} = client, deal_id, attrs) do
    body = WriteAttrs.take(attrs, @write_fields)

    client
    |> Request.patch("deals/:id", body, opts: [path_params: [id: deal_id]])
    |> Response.map([200], fn %{body: %{"data" => deal_data}} ->
      Deal.new(deal_data)
    end)
  end

  @doc """
  Deletes a deal via `DELETE /api/v2/deals/:id`.
  """
  def delete(%Client{} = client, deal_id) do
    client
    |> Request.delete("deals/:id", opts: [path_params: [id: deal_id]])
    |> Response.map([200], fn %{body: body} -> body end)
  end

  @doc """
  Lists one page of deals via API v2 cursor pagination.

  Options: `:cursor`, `:limit` (clamped to 500), `:status`, and other filters.
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
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))

    query =
      opts
      |> Keyword.take([:cursor, :status, :owner_id, :person_id, :org_id, :pipeline_id, :stage_id])
      |> Keyword.put(:limit, limit)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    client
    |> Request.get("deals", query: query)
    |> Response.map([200], fn %{body: body} ->
      items =
        body
        |> Map.get("data")
        |> List.wrap()
        |> Enum.map(&Deal.new/1)

      Page.from_items(items, body)
    end)
  end

  def stream_deals(%Client{} = client, opts \\ []) do
    Cursor.stream(
      fn page_opts ->
        list_deals_page(client, Keyword.merge(opts, page_opts))
      end,
      opts
    )
  end

  # --- API v1 (legacy) ---

  def get_deal(%Client{} = client, deal_id) do
    client
    |> Request.get("deals/:id", api_version: :v1, opts: [path_params: [id: deal_id]])
    |> Response.map([200], fn %{body: %{"data" => deal_data}} ->
      Deal.new(deal_data)
    end)
  end

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
