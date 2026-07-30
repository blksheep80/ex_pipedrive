defmodule ExPipedrive.Deals do
  @moduledoc """
  This module encapsulates calls to the pipedrive deals resource API
  """

  alias ExPipedrive.Deal
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
