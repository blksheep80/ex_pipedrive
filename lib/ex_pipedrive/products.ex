defmodule ExPipedrive.Products do
  @moduledoc """
  Pipedrive products resource.

  v2-first helpers (`get/2`, `create/2`, `update/3`, `delete/2`, `list_page/2`,
  `stream/2`) talk to `/api/v2/products`.

  Product variations (`/api/v2/products/:id/variations`) are deferred to a
  follow-up — use the raw request helpers if you need them sooner.
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.Page
  alias ExPipedrive.Product
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    name code description unit tax category owner_id is_linkable visible_to
    prices custom_fields billing_frequency billing_frequency_cycles
  )

  @doc """
  Fetches a product by id via `GET /api/v2/products/:id`.
  """
  def get(%Client{} = client, product_id) do
    client
    |> Request.get("products/:id", opts: [path_params: [id: product_id]])
    |> Response.map([200], fn %{body: %{"data" => product_data}} ->
      Product.new(product_data)
    end)
  end

  @doc """
  Creates a product via `POST /api/v2/products`.

  Accepts a map (preferred) or `%Product{}`. Returns `{:ok, %Product{}}`.
  """
  def create(%Client{} = client, attrs) do
    body = WriteAttrs.take(attrs, @write_fields)

    client
    |> Request.post("products", body)
    |> Response.map([201], fn %{body: %{"data" => product_data}} ->
      Product.new(product_data)
    end)
  end

  @doc """
  Updates a product via `PATCH /api/v2/products/:id`.
  """
  def update(%Client{} = client, product_id, attrs) do
    body = WriteAttrs.take(attrs, @write_fields)

    client
    |> Request.patch("products/:id", body, opts: [path_params: [id: product_id]])
    |> Response.map([200], fn %{body: %{"data" => product_data}} ->
      Product.new(product_data)
    end)
  end

  @doc """
  Deletes a product via `DELETE /api/v2/products/:id`.
  """
  def delete(%Client{} = client, product_id) do
    client
    |> Request.delete("products/:id", opts: [path_params: [id: product_id]])
    |> Response.map([200], fn %{body: body} -> body end)
  end

  @doc """
  Lists one page of products via API v2 cursor pagination.

  Options: `:cursor`, `:limit` (clamped to 500), `:owner_id`, `:ids`,
  `:filter_id`, `:sort_by`, `:sort_direction`, `:updated_since`, `:custom_fields`.
  """
  def list_page(%Client{} = client, opts \\ []) do
    list_products_page(client, opts)
  end

  @doc """
  Lazily streams products across all v2 cursor pages until `next_cursor` is nil.
  """
  def stream(%Client{} = client, opts \\ []) do
    stream_products(client, opts)
  end

  def list_products_page(%Client{} = client, opts \\ []) do
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))

    query =
      opts
      |> Keyword.take([
        :cursor,
        :owner_id,
        :ids,
        :filter_id,
        :sort_by,
        :sort_direction,
        :updated_since,
        :custom_fields
      ])
      |> Keyword.put(:limit, limit)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    client
    |> Request.get("products", query: query)
    |> Response.map([200], fn %{body: body} ->
      items =
        body
        |> Map.get("data")
        |> List.wrap()
        |> Enum.map(&Product.new/1)

      Page.from_items(items, body)
    end)
  end

  def stream_products(%Client{} = client, opts \\ []) do
    Cursor.stream(
      fn page_opts ->
        list_products_page(client, Keyword.merge(opts, page_opts))
      end,
      opts
    )
  end
end
