defmodule ExPipedrive.Recents do
  @moduledoc """
  API v1 client for Pipedrive recent changes.

  Routes to `/api/v1/recents` (`recents:read` / `search:read` OAuth scopes).
  There is no `/api/v2` equivalent.
  """

  alias ExPipedrive.PagedResult
  alias ExPipedrive.Recent
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  @doc """
  Lists recent changes via `GET /api/v1/recents`.

  Requires `:since_timestamp` (`"YYYY-MM-DD HH:MM:SS"` UTC).

  Options: `:items` (comma-separated types or a list), `:start`, `:limit`.

  Returns `{:ok, %PagedResult{data: [%Recent{}]}}`.
  """
  @spec list(Client.t(), keyword()) :: {:ok, PagedResult.t()} | {:error, ExPipedrive.Error.t()}
  def list(%Client{} = client, opts) when is_list(opts) do
    since = Keyword.fetch!(opts, :since_timestamp)
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit)

    query =
      [since_timestamp: since, start: start]
      |> maybe_put(:limit, limit)
      |> maybe_put(:items, format_items(Keyword.get(opts, :items)))

    client
    |> Request.get("recents", api_version: :v1, query: query)
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], ensure_additional_data(body))

      %{body: %{"success" => true, "data" => data} = body} when is_list(data) ->
        PagedResult.new(Enum.map(data, &Recent.new/1), ensure_additional_data(body))
    end)
  end

  defp format_items(nil), do: nil
  defp format_items(items) when is_binary(items), do: items
  defp format_items(items) when is_list(items), do: Enum.join(items, ",")

  defp maybe_put(query, _key, nil), do: query
  defp maybe_put(query, key, value), do: Keyword.put(query, key, value)

  defp ensure_additional_data(%{"additional_data" => _} = body), do: body

  defp ensure_additional_data(body) do
    Map.put(body, "additional_data", %{"pagination" => %{"start" => 0, "limit" => 100}})
  end
end
