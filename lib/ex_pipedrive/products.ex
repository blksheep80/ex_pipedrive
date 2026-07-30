defmodule ExPipedrive.Products do
  @moduledoc """
  Pipedrive products resource.

  v2-first helpers (`get/2`, `create/2`, `update/3`, `delete/2`, `list_page/2`,
  `stream/2`) talk to `/api/v2/products` via `ExPipedrive.Resource`.

  Product variations (`/api/v2/products/:id/variations`) are deferred to a
  follow-up — use `ExPipedrive.Raw.request/4` if you need them sooner.
  """

  @behaviour ExPipedrive.Resource

  alias ExPipedrive.Product
  alias ExPipedrive.Resource
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    name code description unit tax category owner_id is_linkable visible_to
    prices custom_fields billing_frequency billing_frequency_cycles
  )

  @impl true
  def path, do: "products"

  @impl true
  def decode(data) when is_map(data), do: Product.new(data)

  @impl true
  def encode(attrs), do: WriteAttrs.take(attrs, @write_fields)

  @impl true
  def list_query_keys do
    [
      :owner_id,
      :ids,
      :filter_id,
      :sort_by,
      :sort_direction,
      :updated_since,
      :custom_fields
    ]
  end

  @doc """
  Fetches a product by id via `GET /api/v2/products/:id`.
  """
  def get(%Client{} = client, product_id) do
    Resource.get(__MODULE__, client, product_id)
  end

  @doc """
  Creates a product via `POST /api/v2/products`.

  Accepts a map (preferred) or `%Product{}`. Returns `{:ok, %Product{}}`.
  """
  def create(%Client{} = client, attrs) do
    Resource.create(__MODULE__, client, attrs, success_statuses: [201])
  end

  @doc """
  Updates a product via `PATCH /api/v2/products/:id`.
  """
  def update(%Client{} = client, product_id, attrs) do
    Resource.update(__MODULE__, client, product_id, attrs)
  end

  @doc """
  Deletes a product via `DELETE /api/v2/products/:id`.
  """
  def delete(%Client{} = client, product_id) do
    Resource.delete(__MODULE__, client, product_id)
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
    Resource.list_page(__MODULE__, client, opts)
  end

  def stream_products(%Client{} = client, opts \\ []) do
    Resource.stream(__MODULE__, client, opts)
  end
end
