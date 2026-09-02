defmodule ExPipedrive.LeadFields do
  @moduledoc """
  API v1 lead field definitions.

  `key` is the hash used in lead custom field payloads; `name` is its
  human-readable label. Use `ExPipedrive.Fields` to resolve between them.
  """

  alias ExPipedrive.Error
  alias ExPipedrive.Field
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  @default_limit 500

  @doc """
  Lists one offset page of lead field definitions via `GET /api/v1/leadFields`.

  Options: `:start` (default `0`), `:limit` (default `500`).

  Returns `{:ok, %PagedResult{data: [%Field{}]}}`.
  """
  @spec list(Client.t(), keyword()) :: {:ok, PagedResult.t()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, @default_limit)

    client
    |> Request.get("leadFields", api_version: :v1, query: [start: start, limit: limit])
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} when is_list(data) ->
        PagedResult.new(Enum.map(data, &Field.new/1), body)
    end)
  end

  @doc """
  Lazily streams lead field definitions across API v1 offset pages.
  """
  @spec stream(Client.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, opts \\ []) do
    limit = Keyword.get(opts, :limit, @default_limit)
    initial_start = Keyword.get(opts, :start, 0)

    Stream.resource(
      fn -> initial_start end,
      &stream_next_page(&1, client, opts, limit),
      fn _ -> :ok end
    )
  end

  @doc """
  Alias for `list/2`.
  """
  @spec list_lead_fields(Client.t(), keyword()) :: {:ok, PagedResult.t()} | {:error, Error.t()}
  def list_lead_fields(%Client{} = client, opts \\ []), do: list(client, opts)

  defp stream_next_page(:done, _client, _opts, _limit), do: {:halt, :done}

  defp stream_next_page(start, client, opts, limit) do
    case list(client, Keyword.merge(opts, start: start, limit: limit)) do
      {:ok, %PagedResult{data: data, additional_data: additional_data}} ->
        next =
          if more_items?(additional_data),
            do: next_start(additional_data, start, length(data)),
            else: :done

        {data, next}

      {:error, %Error{} = error} ->
        raise error
    end
  end

  defp more_items?(%{pagination: %{more_items_in_collection: true}}), do: true
  defp more_items?(_), do: false

  defp next_start(%{pagination: %{start: start, limit: limit}}, _fallback_start, _count),
    do: start + limit

  defp next_start(_additional_data, start, count), do: start + count
end
