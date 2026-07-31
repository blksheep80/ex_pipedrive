defmodule ExPipedrive.ProductVariations do
  @moduledoc """
  Pipedrive product variations resource — nested under a product id.

  Variations are a separate v2 API from `ExPipedrive.Products`:
  `/api/v2/products/:id/variations`. Because every call is scoped to a
  `product_id` (unlike the single flat top-level path assumed by
  `ExPipedrive.Resource`), this module builds its own `Request` calls rather
  than implementing the `Resource` behaviour.

  Pipedrive does not expose a "get one variation" endpoint — only
  list/create/update/delete. `get/3` is a client-side convenience that scans
  `stream/3` pages for a matching id.

  ## Example

      {:ok, variation} =
        ExPipedrive.ProductVariations.create(client, product_id, %{
          name: "Large",
          prices: [%{currency: "USD", price: 24.99}]
        })

      {:ok, page} = ExPipedrive.ProductVariations.list_page(client, product_id)
      variations = ExPipedrive.ProductVariations.stream(client, product_id) |> Enum.to_list()

      {:ok, updated} =
        ExPipedrive.ProductVariations.update(client, product_id, variation.id, %{name: "XL"})

      {:ok, _} = ExPipedrive.ProductVariations.delete(client, product_id, variation.id)
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.Error
  alias ExPipedrive.Page
  alias ExPipedrive.ProductVariation
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(name prices)

  @doc """
  Lists one page of a product's variations via
  `GET /api/v2/products/:id/variations`.

  Options: `:cursor`, `:limit` (clamped to 500). Returns `{:ok, %ExPipedrive.Page{}}`.
  """
  @spec list_page(Client.t(), term(), keyword()) :: {:ok, Page.t()} | {:error, Error.t()}
  def list_page(%Client{} = client, product_id, opts \\ []) do
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))

    query =
      [cursor: Keyword.get(opts, :cursor), limit: limit]
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    client
    |> Request.get("products/:product_id/variations",
      query: query,
      opts: [path_params: [product_id: product_id]]
    )
    |> Response.map([200], fn %{body: body} ->
      items =
        body
        |> Map.get("data")
        |> List.wrap()
        |> Enum.map(&ProductVariation.new/1)

      Page.from_items(items, body)
    end)
  end

  @doc """
  Lazily streams a product's variations across all v2 cursor pages until
  `next_cursor` is nil.
  """
  @spec stream(Client.t(), term(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, product_id, opts \\ []) do
    Cursor.stream(
      fn page_opts -> list_page(client, product_id, Keyword.merge(opts, page_opts)) end,
      opts
    )
  end

  @doc """
  Fetches a single product variation by id.

  Pipedrive has no dedicated "get one variation" endpoint, so this scans
  `stream/3` pages for a matching `id` and returns a structured `:not_found`
  error (mirroring a 404 API response) when it isn't present.
  """
  @spec get(Client.t(), term(), term()) :: {:ok, ProductVariation.t()} | {:error, Error.t()}
  def get(%Client{} = client, product_id, variation_id) do
    client
    |> stream(product_id)
    |> Enum.find(fn %ProductVariation{id: id} -> id == variation_id end)
    |> case do
      %ProductVariation{} = variation ->
        {:ok, variation}

      nil ->
        {:error,
         %Error{
           kind: :not_found,
           status: 404,
           message:
             "product variation #{inspect(variation_id)} not found on product #{inspect(product_id)}"
         }}
    end
  end

  @doc """
  Creates a product variation via `POST /api/v2/products/:id/variations`.

  Accepts a map (preferred) or `%ProductVariation{}`. Required: `:name`.
  Optional: `:prices` (array of `%{currency:, price:, cost:, direct_cost:, notes:}`).
  """
  @spec create(Client.t(), term(), term()) ::
          {:ok, ProductVariation.t()} | {:error, Error.t()}
  def create(%Client{} = client, product_id, attrs) do
    body = WriteAttrs.take(attrs, @write_fields)

    client
    |> Request.post("products/:product_id/variations", body,
      opts: [path_params: [product_id: product_id]]
    )
    |> Response.map([200, 201], fn %{body: %{"data" => data}} -> ProductVariation.new(data) end)
  end

  @doc """
  Updates a product variation via
  `PATCH /api/v2/products/:id/variations/:product_variation_id`.
  """
  @spec update(Client.t(), term(), term(), term()) ::
          {:ok, ProductVariation.t()} | {:error, Error.t()}
  def update(%Client{} = client, product_id, variation_id, attrs) do
    body = WriteAttrs.take(attrs, @write_fields)

    client
    |> Request.patch("products/:product_id/variations/:id", body,
      opts: [path_params: [product_id: product_id, id: variation_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} -> ProductVariation.new(data) end)
  end

  @doc """
  Deletes a product variation via
  `DELETE /api/v2/products/:id/variations/:product_variation_id`.
  """
  @spec delete(Client.t(), term(), term()) :: {:ok, term()} | {:error, Error.t()}
  def delete(%Client{} = client, product_id, variation_id) do
    client
    |> Request.delete("products/:product_id/variations/:id",
      opts: [path_params: [product_id: product_id, id: variation_id]]
    )
    |> Response.map([200], fn %{body: body} -> body end)
  end
end
