defmodule ExPipedrive.Roles do
  @moduledoc """
  API v1 client for Pipedrive roles (visibility groups).

  Read-first surface against `/api/v1/roles`. Role create/update/delete and
  assignment writes are deferred; use `ExPipedrive.Raw` if needed.
  """

  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.Role
  alias ExPipedrive.RoleAssignment
  alias Tesla.Client

  @doc """
  Lists roles via `GET /api/v1/roles`.

  Returns `{:ok, [%Role{}]}`.
  """
  @spec list(Client.t()) :: {:ok, [Role.t()]} | {:error, ExPipedrive.Error.t()}
  def list(%Client{} = client) do
    client
    |> Request.get("roles", api_version: :v1)
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil}} ->
        []

      %{body: %{"success" => true, "data" => data}} when is_list(data) ->
        Enum.map(data, &Role.new/1)
    end)
  end

  @doc """
  Fetches a role via `GET /api/v1/roles/:id`.

  Returns `{:ok, %Role{}}`.
  """
  @spec get(Client.t(), pos_integer()) :: {:ok, Role.t()} | {:error, ExPipedrive.Error.t()}
  def get(%Client{} = client, role_id) when is_integer(role_id) do
    client
    |> Request.get("roles/:id", api_version: :v1, opts: [path_params: [id: role_id]])
    |> Response.map([200], fn %{body: %{"data" => data}} when is_map(data) ->
      Role.new(data)
    end)
  end

  @doc """
  Lists role assignments via `GET /api/v1/roles/:id/assignments`.

  Options: `:start`, `:limit`. Returns `{:ok, %PagedResult{}}`.
  """
  @spec list_assignments(Client.t(), pos_integer(), keyword()) ::
          {:ok, PagedResult.t()} | {:error, ExPipedrive.Error.t()}
  def list_assignments(%Client{} = client, role_id, opts \\ []) when is_integer(role_id) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit)

    query =
      [start: start]
      |> then(fn q -> if limit, do: Keyword.put(q, :limit, limit), else: q end)

    client
    |> Request.get("roles/:id/assignments",
      api_version: :v1,
      query: query,
      opts: [path_params: [id: role_id]]
    )
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], ensure_additional_data(body))

      %{body: %{"success" => true, "data" => data} = body} when is_list(data) ->
        PagedResult.new(Enum.map(data, &RoleAssignment.new/1), ensure_additional_data(body))
    end)
  end

  @doc """
  Lists pipeline visibility for a role via `GET /api/v1/roles/:id/pipelines`.

  Returns `{:ok, map()}` — the Pipedrive `data` payload as decoded JSON.
  """
  @spec list_pipelines(Client.t(), pos_integer()) ::
          {:ok, map() | list()} | {:error, ExPipedrive.Error.t()}
  def list_pipelines(%Client{} = client, role_id) when is_integer(role_id) do
    client
    |> Request.get("roles/:id/pipelines",
      api_version: :v1,
      opts: [path_params: [id: role_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} -> data end)
  end

  @doc """
  Lists role settings via `GET /api/v1/roles/:id/settings`.

  Returns `{:ok, map()}` — the Pipedrive `data` payload as decoded JSON.
  """
  @spec list_settings(Client.t(), pos_integer()) ::
          {:ok, map()} | {:error, ExPipedrive.Error.t()}
  def list_settings(%Client{} = client, role_id) when is_integer(role_id) do
    client
    |> Request.get("roles/:id/settings",
      api_version: :v1,
      opts: [path_params: [id: role_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} -> data end)
  end

  defp ensure_additional_data(%{"additional_data" => _} = body), do: body

  defp ensure_additional_data(body) do
    Map.put(body, "additional_data", %{"pagination" => %{"start" => 0, "limit" => 100}})
  end
end
