defmodule ExPipedrive.Teams do
  @moduledoc """
  API v1 client for Pipedrive legacy teams.

  Calls `/api/v1/legacyTeams` (formerly `/api/v1/teams`). Read-first surface;
  team create/update/membership writes are deferred — use `ExPipedrive.Raw`
  if needed. The endpoint is marked deprecated by Pipedrive pending a
  replacement Teams API; behaviour and OAuth scopes (`users:read` /
  `users:full`) are unchanged.
  """

  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.Team
  alias Tesla.Client

  @doc """
  Lists teams via `GET /api/v1/legacyTeams`.

  Options: `:order_by` (`"id"` | `"name"` | `"manager_id"` | `"active_flag"`),
  `:skip_users` (`true`/`false` or `0`/`1`).

  Returns `{:ok, [%Team{}]}`.
  """
  @spec list(Client.t(), keyword()) :: {:ok, [Team.t()]} | {:error, ExPipedrive.Error.t()}
  def list(%Client{} = client, opts \\ []) do
    query =
      []
      |> maybe_put(:order_by, Keyword.get(opts, :order_by))
      |> maybe_put(:skip_users, skip_users_int(Keyword.get(opts, :skip_users)))

    client
    |> Request.get("legacyTeams", api_version: :v1, query: query)
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil}} ->
        []

      %{body: %{"success" => true, "data" => data}} when is_list(data) ->
        Enum.map(data, &Team.new/1)
    end)
  end

  @doc """
  Fetches a team via `GET /api/v1/legacyTeams/:id`.

  Returns `{:ok, %Team{}}`.
  """
  @spec get(Client.t(), pos_integer()) :: {:ok, Team.t()} | {:error, ExPipedrive.Error.t()}
  def get(%Client{} = client, team_id) when is_integer(team_id) do
    client
    |> Request.get("legacyTeams/:id",
      api_version: :v1,
      opts: [path_params: [id: team_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} when is_map(data) ->
      Team.new(data)
    end)
  end

  @doc """
  Lists user ids in a team via `GET /api/v1/legacyTeams/:id/users`.

  Returns `{:ok, [user_id]}`.
  """
  @spec list_users(Client.t(), pos_integer()) ::
          {:ok, [pos_integer()]} | {:error, ExPipedrive.Error.t()}
  def list_users(%Client{} = client, team_id) when is_integer(team_id) do
    client
    |> Request.get("legacyTeams/:id/users",
      api_version: :v1,
      opts: [path_params: [id: team_id]]
    )
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil}} -> []
      %{body: %{"success" => true, "data" => data}} when is_list(data) -> data
    end)
  end

  @doc """
  Lists teams for a user via `GET /api/v1/legacyTeams/user/:id`.

  Returns `{:ok, [%Team{}]}`.
  """
  @spec list_for_user(Client.t(), pos_integer()) ::
          {:ok, [Team.t()]} | {:error, ExPipedrive.Error.t()}
  def list_for_user(%Client{} = client, user_id) when is_integer(user_id) do
    client
    |> Request.get("legacyTeams/user/:id",
      api_version: :v1,
      opts: [path_params: [id: user_id]]
    )
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil}} ->
        []

      %{body: %{"success" => true, "data" => data}} when is_list(data) ->
        Enum.map(data, &Team.new/1)
    end)
  end

  defp maybe_put(query, _key, nil), do: query
  defp maybe_put(query, key, value), do: Keyword.put(query, key, value)

  defp skip_users_int(nil), do: nil
  defp skip_users_int(true), do: 1
  defp skip_users_int(false), do: 0
  defp skip_users_int(0), do: 0
  defp skip_users_int(1), do: 1
end
