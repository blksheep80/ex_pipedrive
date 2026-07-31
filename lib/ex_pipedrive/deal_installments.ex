defmodule ExPipedrive.DealInstallments do
  @moduledoc """
  Pipedrive deal-installments resource — scheduled payment entries on deals.

  API v2 only. **Growth plan and above** (per Pipedrive OpenAPI).

  There is no `GET /api/v2/deals/:id/installments`; list installments with
  `GET /api/v2/deals/installments?deal_ids=...` (required `deal_ids`).

  ## Example

      {:ok, page} =
        ExPipedrive.DealInstallments.list_page(client, deal_ids: [1, 2])

      {:ok, installment} =
        ExPipedrive.DealInstallments.create(client, 1, %{
          description: "Delivery Fee",
          amount: 10,
          billing_date: "2025-03-10"
        })

      {:ok, installment} =
        ExPipedrive.DealInstallments.update(client, 1, installment.id, %{
          amount: 15
        })

      {:ok, :ok} = ExPipedrive.DealInstallments.delete(client, 1, installment.id)
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.DealInstallment
  alias ExPipedrive.Error
  alias ExPipedrive.Page
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(description amount billing_date)

  @doc """
  Lists one page of installments via `GET /api/v2/deals/installments`.

  Requires `:deal_ids` — a list of deal ids or a comma-separated string (max
  100 ids per Pipedrive).

  Options: `:cursor`, `:limit` (clamped to 500), `:sort_by`, `:sort_direction`.
  """
  @spec list_page(Client.t(), keyword()) :: {:ok, Page.t()} | {:error, Error.t()}
  def list_page(%Client{} = client, opts) when is_list(opts) do
    deal_ids = Keyword.fetch!(opts, :deal_ids)
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))

    query =
      [
        deal_ids: format_deal_ids(deal_ids),
        cursor: Keyword.get(opts, :cursor),
        limit: limit,
        sort_by: Keyword.get(opts, :sort_by),
        sort_direction: Keyword.get(opts, :sort_direction)
      ]
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    client
    |> Request.get("deals/installments", query: query)
    |> Response.map([200], fn %{body: body} ->
      items =
        body
        |> Map.get("data")
        |> List.wrap()
        |> Enum.map(&DealInstallment.new/1)

      Page.from_items(items, body)
    end)
  end

  @doc """
  Lazily streams deal-installments across v2 cursor pages.

  Requires `:deal_ids` (see `list_page/2`).
  """
  @spec stream(Client.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, opts) when is_list(opts) do
    Cursor.stream(
      fn page_opts -> list_page(client, Keyword.merge(opts, page_opts)) end,
      opts
    )
  end

  @doc """
  Adds an installment to a deal via `POST /api/v2/deals/:id/installments`.

  Requires `:description`, `:amount`, and `:billing_date`.
  """
  @spec create(Client.t(), term(), map()) ::
          {:ok, DealInstallment.t()} | {:error, Error.t()}
  def create(%Client{} = client, deal_id, attrs) when is_map(attrs) do
    client
    |> Request.post("deals/:deal_id/installments", WriteAttrs.take(attrs, @write_fields),
      opts: [path_params: [deal_id: deal_id]]
    )
    |> Response.map([200, 201], fn %{body: %{"data" => data}} -> DealInstallment.new(data) end)
  end

  @doc """
  Updates a deal-installment via
  `PATCH /api/v2/deals/:id/installments/:installment_id`.
  """
  @spec update(Client.t(), term(), term(), map()) ::
          {:ok, DealInstallment.t()} | {:error, Error.t()}
  def update(%Client{} = client, deal_id, installment_id, attrs) when is_map(attrs) do
    client
    |> Request.patch(
      "deals/:deal_id/installments/:installment_id",
      WriteAttrs.take(attrs, @write_fields),
      opts: [path_params: [deal_id: deal_id, installment_id: installment_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} -> DealInstallment.new(data) end)
  end

  @doc """
  Deletes one deal-installment via
  `DELETE /api/v2/deals/:id/installments/:installment_id`.
  """
  @spec delete(Client.t(), term(), term()) :: {:ok, :ok} | {:error, Error.t()}
  def delete(%Client{} = client, deal_id, installment_id) do
    client
    |> Request.delete("deals/:deal_id/installments/:installment_id",
      opts: [path_params: [deal_id: deal_id, installment_id: installment_id]]
    )
    |> Response.map([200], fn _env -> :ok end)
  end

  defp format_deal_ids(ids) when is_binary(ids), do: ids
  defp format_deal_ids(ids) when is_list(ids), do: Enum.join(ids, ",")
end
