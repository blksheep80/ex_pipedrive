defmodule ExPipedrive.Users do
  @moduledoc """
  API v1 shim for Pipedrive users.

  All functions in this module explicitly route to `/api/v1/users`. A v2 Users
  resource can replace this shim without changing callers.
  """

  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.User
  alias Tesla.Client

  @doc """
  Fetches the current (authenticated) user through `GET /api/v1/users/me`.
  """
  def me(%Client{} = client) do
    client
    |> Request.get("users/me", api_version: :v1)
    |> Response.map([200], fn %{body: %{"data" => user_data}} ->
      User.new(user_data)
    end)
  end

  @doc """
  Fetches a user by id through `GET /api/v1/users/:id`.
  """
  def get(%Client{} = client, user_id) do
    client
    |> Request.get("users/:id", api_version: :v1, opts: [path_params: [id: user_id]])
    |> Response.map([200], fn %{body: %{"data" => user_data}} ->
      User.new(user_data)
    end)
  end

  @doc """
  Lists users through `GET /api/v1/users`.

  Supports the same `:start` / `:limit` offset pagination options as
  `ExPipedrive.Notes.list/2`.
  """
  def list(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 100)

    client
    |> Request.get("users", api_version: :v1, query: [start: start, limit: limit])
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} ->
        PagedResult.new(Enum.map(data, &User.new/1), body)
    end)
  end

  @doc """
  Finds users by name (or email) through `GET /api/v1/users/find`.
  """
  def find_users_by_name(%Client{} = client, term, opts \\ []) do
    search_by_email? = Keyword.get(opts, :search_by_email?, false)

    client
    |> Request.get("users/find",
      api_version: :v1,
      query: [term: term, search_by_email: search_int(search_by_email?)]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      Enum.map(data, &User.new/1)
    end)
  end

  defp search_int(true), do: 1
  defp search_int(false), do: 0
end
