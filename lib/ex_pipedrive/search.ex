defmodule ExPipedrive.Search do
  @moduledoc """
  Pipedrive item search (API v2).

  Wraps `GET /api/v2/itemSearch` with cursor pagination. Nested
  `data.items[].item` entries are unwrapped into `ExPipedrive.SearchResult`.

  Per-resource helpers (`search_deals/3`, `search_persons/3`,
  `search_organizations/3`) set `item_types` and return the same page shape.

  Legacy v1 resource search (`Deals.search_deals/3`, etc.) remains available for
  compatibility. Upstream LineDrive PR #22 (pass-through search opts) is covered
  here via explicit v2 options rather than opaque keyword merging — see GitHub #24.
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.Page
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.SearchResult
  alias Tesla.Client

  @max_limit 100
  @default_limit 100

  @query_keys [
    :item_types,
    :fields,
    :exact_match,
    :include_fields,
    :search_for_related_items,
    :custom_fields,
    :cursor
  ]

  @doc """
  Searches across item types via `GET /api/v2/itemSearch`.

  Returns one cursor page of `%ExPipedrive.SearchResult{}`.

  ## Options

  - `:item_types` — list or comma-separated string (`deal`, `person`,
    `organization`, `product`, `lead`, …)
  - `:fields` — list or comma-separated searchable fields
  - `:exact_match` — boolean
  - `:include_fields` — list or comma-separated optional fields
  - `:search_for_related_items` — boolean
  - `:custom_fields` — hash of searchable custom field keys
  - `:cursor` / `:limit` — cursor pagination (`limit` clamped to 1..100)

  ## Example

      {:ok, %ExPipedrive.Page{data: results}} =
        ExPipedrive.Search.search_page(client, "acme", item_types: ["organization", "person"])

      Enum.map(results, & &1.item)
  """
  @spec search_page(Client.t(), String.t(), keyword()) ::
          {:ok, Page.t()} | {:error, ExPipedrive.Error.t()}
  def search_page(%Client{} = client, term, opts \\ []) when is_binary(term) do
    limit = clamp_limit(Keyword.get(opts, :limit))

    query =
      opts
      |> Keyword.take(@query_keys)
      |> normalize_query()
      |> Keyword.put(:term, term)
      |> Keyword.put(:limit, limit)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    client
    |> Request.get("itemSearch", query: query)
    |> Response.map([200], fn %{body: body} ->
      items =
        body
        |> Map.get("data")
        |> Kernel.||(%{})
        |> Map.get("items")
        |> List.wrap()
        |> Enum.map(&SearchResult.new/1)

      Page.from_items(items, body)
    end)
  end

  @doc """
  Lazily streams search results across all v2 cursor pages until `next_cursor` is nil.
  """
  @spec stream(Client.t(), String.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, term, opts \\ []) when is_binary(term) do
    Cursor.stream(
      fn page_opts ->
        search_page(client, term, Keyword.merge(opts, page_opts))
      end,
      Keyword.put(opts, :limit, clamp_limit(Keyword.get(opts, :limit)))
    )
  end

  @doc """
  Searches deals only (`item_types=deal`).
  """
  @spec search_deals(Client.t(), String.t(), keyword()) ::
          {:ok, Page.t()} | {:error, ExPipedrive.Error.t()}
  def search_deals(%Client{} = client, term, opts \\ []) do
    search_page(client, term, Keyword.put(opts, :item_types, "deal"))
  end

  @doc """
  Searches persons only (`item_types=person`).
  """
  @spec search_persons(Client.t(), String.t(), keyword()) ::
          {:ok, Page.t()} | {:error, ExPipedrive.Error.t()}
  def search_persons(%Client{} = client, term, opts \\ []) do
    search_page(client, term, Keyword.put(opts, :item_types, "person"))
  end

  @doc """
  Searches organizations only (`item_types=organization`).
  """
  @spec search_organizations(Client.t(), String.t(), keyword()) ::
          {:ok, Page.t()} | {:error, ExPipedrive.Error.t()}
  def search_organizations(%Client{} = client, term, opts \\ []) do
    search_page(client, term, Keyword.put(opts, :item_types, "organization"))
  end

  @doc """
  Maximum page size for itemSearch (Pipedrive caps at 100).
  """
  @spec max_limit() :: pos_integer()
  def max_limit, do: @max_limit

  defp clamp_limit(nil), do: @default_limit

  defp clamp_limit(limit) when is_integer(limit) and limit > 0 do
    min(limit, @max_limit)
  end

  defp clamp_limit(_), do: @default_limit

  defp normalize_query(opts) do
    Enum.map(opts, fn
      {key, value} when key in [:item_types, :fields, :include_fields] ->
        {key, join_csv(value)}

      {key, value} when key in [:exact_match, :search_for_related_items] ->
        {key, bool_param(value)}

      other ->
        other
    end)
  end

  defp join_csv(nil), do: nil
  defp join_csv(list) when is_list(list), do: Enum.map_join(list, ",", &to_string/1)
  defp join_csv(value) when is_atom(value), do: to_string(value)
  defp join_csv(value) when is_binary(value), do: value
  defp join_csv(value), do: to_string(value)

  defp bool_param(nil), do: nil
  defp bool_param(true), do: true
  defp bool_param(false), do: false
  defp bool_param(1), do: true
  defp bool_param(0), do: false
  defp bool_param(value), do: value
end
