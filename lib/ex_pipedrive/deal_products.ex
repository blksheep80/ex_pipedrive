defmodule ExPipedrive.DealProducts do
  @moduledoc """
  Pipedrive deal-products resource — products attached to a deal.

  Nested under a deal id on API v2: `/api/v2/deals/:id/products`. Distinct
  from the catalog `ExPipedrive.Products` API.

  ## Example

      {:ok, page} = ExPipedrive.DealProducts.list_page(client, deal_id)

      {:ok, attachment} =
        ExPipedrive.DealProducts.create(client, deal_id, %{
          product_id: 1,
          item_price: 90,
          quantity: 1
        })

      {:ok, attachment} =
        ExPipedrive.DealProducts.update(client, deal_id, attachment.id, %{quantity: 2})

      {:ok, :ok} = ExPipedrive.DealProducts.delete(client, deal_id, attachment.id)
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.DealProduct
  alias ExPipedrive.Error
  alias ExPipedrive.Page
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    product_id item_price quantity tax comments discount is_enabled tax_method
    discount_type product_variation_id billing_frequency billing_frequency_cycles
    billing_start_date
  )

  @doc """
  Lists one page of products attached to a deal via
  `GET /api/v2/deals/:id/products`.

  Options: `:cursor`, `:limit` (clamped to 500), `:sort_by`, `:sort_direction`.
  """
  @spec list_page(Client.t(), term(), keyword()) :: {:ok, Page.t()} | {:error, Error.t()}
  def list_page(%Client{} = client, deal_id, opts \\ []) do
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))

    query =
      [
        cursor: Keyword.get(opts, :cursor),
        limit: limit,
        sort_by: Keyword.get(opts, :sort_by),
        sort_direction: Keyword.get(opts, :sort_direction)
      ]
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    client
    |> Request.get("deals/:deal_id/products",
      query: query,
      opts: [path_params: [deal_id: deal_id]]
    )
    |> Response.map([200], fn %{body: body} ->
      items =
        body
        |> Map.get("data")
        |> List.wrap()
        |> Enum.map(&DealProduct.new/1)

      Page.from_items(items, body)
    end)
  end

  @doc """
  Lazily streams deal-products across v2 cursor pages.
  """
  @spec stream(Client.t(), term(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, deal_id, opts \\ []) do
    Cursor.stream(
      fn page_opts -> list_page(client, deal_id, Keyword.merge(opts, page_opts)) end,
      opts
    )
  end

  @doc """
  Fetches one deal-product by attachment id (client-side over `stream/3`).

  Pipedrive has no single-get endpoint for deal-products.
  """
  @spec get(Client.t(), term(), term()) :: {:ok, DealProduct.t()} | {:error, Error.t()}
  def get(%Client{} = client, deal_id, attachment_id) do
    case Enum.find(stream(client, deal_id), &(&1.id == attachment_id)) do
      nil ->
        {:error,
         %Error{
           kind: :not_found,
           message: "Deal product #{attachment_id} not found on deal #{deal_id}",
           status: 404,
           body: nil,
           headers: [],
           request_id: nil,
           rate_limit: nil,
           reason: nil
         }}

      deal_product ->
        {:ok, deal_product}
    end
  end

  @doc """
  Attaches a product to a deal via `POST /api/v2/deals/:id/products`.

  Requires `:product_id`, `:item_price`, and `:quantity`.
  """
  @spec create(Client.t(), term(), map()) :: {:ok, DealProduct.t()} | {:error, Error.t()}
  def create(%Client{} = client, deal_id, attrs) when is_map(attrs) do
    client
    |> Request.post("deals/:deal_id/products", WriteAttrs.take(attrs, @write_fields),
      opts: [path_params: [deal_id: deal_id]]
    )
    |> Response.map([200, 201], fn %{body: %{"data" => data}} -> DealProduct.new(data) end)
  end

  @doc """
  Updates a deal-product via `PATCH /api/v2/deals/:id/products/:product_attachment_id`.
  """
  @spec update(Client.t(), term(), term(), map()) ::
          {:ok, DealProduct.t()} | {:error, Error.t()}
  def update(%Client{} = client, deal_id, attachment_id, attrs) when is_map(attrs) do
    client
    |> Request.patch(
      "deals/:deal_id/products/:attachment_id",
      WriteAttrs.take(attrs, @write_fields),
      opts: [path_params: [deal_id: deal_id, attachment_id: attachment_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} -> DealProduct.new(data) end)
  end

  @doc """
  Deletes one deal-product via
  `DELETE /api/v2/deals/:id/products/:product_attachment_id`.
  """
  @spec delete(Client.t(), term(), term()) :: {:ok, :ok} | {:error, Error.t()}
  def delete(%Client{} = client, deal_id, attachment_id) do
    client
    |> Request.delete("deals/:deal_id/products/:attachment_id",
      opts: [path_params: [deal_id: deal_id, attachment_id: attachment_id]]
    )
    |> Response.map([200], fn _env -> :ok end)
  end

  @doc """
  Deletes many deal-products via `DELETE /api/v2/deals/:id/products`.

  Options: `:ids` — list of attachment ids (or comma-separated string). When
  omitted, Pipedrive deletes up to 100 attachments on the deal.

  Returns `{:ok, [id]}` of deleted attachment ids.
  """
  @spec delete_many(Client.t(), term(), keyword()) ::
          {:ok, [pos_integer()]} | {:error, Error.t()}
  def delete_many(%Client{} = client, deal_id, opts \\ []) do
    query =
      case Keyword.get(opts, :ids) do
        nil -> []
        ids when is_list(ids) -> [ids: Enum.join(ids, ",")]
        ids when is_binary(ids) -> [ids: ids]
      end

    client
    |> Request.delete("deals/:deal_id/products",
      query: query,
      opts: [path_params: [deal_id: deal_id]]
    )
    |> Response.map([200], fn
      %{body: %{"data" => %{"ids" => ids}}} when is_list(ids) -> ids
      %{body: %{"data" => nil}} -> []
    end)
  end
end
