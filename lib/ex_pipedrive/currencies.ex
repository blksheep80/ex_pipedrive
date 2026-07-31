defmodule ExPipedrive.Currencies do
  @moduledoc """
  API v1 client for Pipedrive currencies.

  Currencies remain on `/api/v1/currencies`; there is no `/api/v2` equivalent
  and no single-currency get endpoint. Use `list/2` (optionally with `:term`)
  and `get/2` / `get_by_code/2` for client-side lookup.
  """

  alias ExPipedrive.Currency
  alias ExPipedrive.Error
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  @doc """
  Lists supported currencies via `GET /api/v1/currencies`.

  Options: `:term` — optional search against currency name and/or code.

  Returns `{:ok, [%Currency{}]}`.
  """
  @spec list(Client.t(), keyword()) :: {:ok, [Currency.t()]} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    query =
      case Keyword.get(opts, :term) do
        nil -> []
        term -> [term: term]
      end

    client
    |> Request.get("currencies", api_version: :v1, query: query)
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil}} ->
        []

      %{body: %{"success" => true, "data" => data}} when is_list(data) ->
        Enum.map(data, &Currency.new/1)
    end)
  end

  @doc """
  Fetches a currency by integer id (client-side over `list/2`).

  Returns `{:ok, %Currency{}}` or `{:error, %Error{kind: :not_found}}`.
  """
  @spec get(Client.t(), pos_integer()) :: {:ok, Currency.t()} | {:error, Error.t()}
  def get(%Client{} = client, id) when is_integer(id) do
    with {:ok, currencies} <- list(client) do
      case Enum.find(currencies, &(&1.id == id)) do
        nil -> {:error, not_found("Currency #{id} not found")}
        currency -> {:ok, currency}
      end
    end
  end

  @doc """
  Fetches a currency by ISO/custom code (client-side over `list/2`).

  Matching is case-insensitive. Returns `{:ok, %Currency{}}` or
  `{:error, %Error{kind: :not_found}}`.
  """
  @spec get_by_code(Client.t(), String.t()) :: {:ok, Currency.t()} | {:error, Error.t()}
  def get_by_code(%Client{} = client, code) when is_binary(code) do
    down = String.downcase(code)

    with {:ok, currencies} <- list(client) do
      case Enum.find(currencies, fn c -> c.code && String.downcase(c.code) == down end) do
        nil -> {:error, not_found("Currency code #{code} not found")}
        currency -> {:ok, currency}
      end
    end
  end

  defp not_found(message) do
    %Error{
      kind: :not_found,
      message: message,
      status: 404,
      body: nil,
      headers: [],
      request_id: nil,
      rate_limit: nil,
      reason: nil
    }
  end
end
