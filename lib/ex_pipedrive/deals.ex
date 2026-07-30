defmodule ExPipedrive.Deals do
  @moduledoc """
  This module encapsulates calls to the pipedrive deals resource API
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.Deal
  alias ExPipedrive.Page
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

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

  @doc """
  Lists one page of deals via API v2 cursor pagination.

  Options: `:cursor`, `:limit` (clamped to 500), plus filter query params
  such as `:status`.
  """
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

  @doc """
  Lazily streams deals across all v2 cursor pages until `next_cursor` is nil.
  """
  def stream_deals(%Client{} = client, opts \\ []) do
    Cursor.stream(
      fn page_opts ->
        list_deals_page(client, Keyword.merge(opts, page_opts))
      end,
      opts
    )
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
end
