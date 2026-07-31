defmodule ExPipedrive.PermissionSets do
  @moduledoc """
  API v1 client for Pipedrive permission sets.

  Read-only surface against `/api/v1/permissionSets` (admin OAuth scope).
  There is no `/api/v2` equivalent.
  """

  alias ExPipedrive.PagedResult
  alias ExPipedrive.PermissionSet
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  @doc """
  Lists permission sets via `GET /api/v1/permissionSets`.

  Options: `:app` — filter by app (`"sales"`, `"projects"`, `"campaigns"`,
  `"global"`, `"account_settings"`).

  Returns `{:ok, [%PermissionSet{}]}`.
  """
  @spec list(Client.t(), keyword()) ::
          {:ok, [PermissionSet.t()]} | {:error, ExPipedrive.Error.t()}
  def list(%Client{} = client, opts \\ []) do
    query =
      case Keyword.get(opts, :app) do
        nil -> []
        app -> [app: app]
      end

    client
    |> Request.get("permissionSets", api_version: :v1, query: query)
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil}} ->
        []

      %{body: %{"success" => true, "data" => data}} when is_list(data) ->
        Enum.map(data, &PermissionSet.new/1)
    end)
  end

  @doc """
  Fetches a permission set via `GET /api/v1/permissionSets/:id`.

  Pipedrive may return `data` as a single object or a one-element list; both
  are accepted. Returns `{:ok, %PermissionSet{}}`.
  """
  @spec get(Client.t(), String.t()) ::
          {:ok, PermissionSet.t()} | {:error, ExPipedrive.Error.t()}
  def get(%Client{} = client, permission_set_id) when is_binary(permission_set_id) do
    client
    |> Request.get("permissionSets/:id",
      api_version: :v1,
      opts: [path_params: [id: permission_set_id]]
    )
    |> Response.map([200], fn
      %{body: %{"data" => data}} when is_map(data) ->
        PermissionSet.new(data)

      %{body: %{"data" => [data | _]}} when is_map(data) ->
        PermissionSet.new(data)
    end)
  end

  @doc """
  Lists users assigned to a permission set via
  `GET /api/v1/permissionSets/:id/assignments`.

  Options: `:start`, `:limit`. Returns `{:ok, %PagedResult{}}` whose `:data`
  is a list of assignment maps (`"user_id"`, …) as returned by Pipedrive.
  """
  @spec list_assignments(Client.t(), String.t(), keyword()) ::
          {:ok, PagedResult.t()} | {:error, ExPipedrive.Error.t()}
  def list_assignments(%Client{} = client, permission_set_id, opts \\ [])
      when is_binary(permission_set_id) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit)

    query =
      [start: start]
      |> then(fn q -> if limit, do: Keyword.put(q, :limit, limit), else: q end)

    client
    |> Request.get("permissionSets/:id/assignments",
      api_version: :v1,
      query: query,
      opts: [path_params: [id: permission_set_id]]
    )
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], ensure_additional_data(body))

      %{body: %{"success" => true, "data" => data} = body} when is_list(data) ->
        PagedResult.new(data, ensure_additional_data(body))
    end)
  end

  defp ensure_additional_data(%{"additional_data" => _} = body), do: body

  defp ensure_additional_data(body) do
    Map.put(body, "additional_data", %{"pagination" => %{"start" => 0, "limit" => 100}})
  end
end
