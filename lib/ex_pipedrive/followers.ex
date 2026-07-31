defmodule ExPipedrive.Followers do
  @moduledoc """
  API v2 client for followers on deals, persons, and organizations.

  Followers moved from v1 to v2 for these three entities (see Pipedrive's
  [/v1 to /v2 migration guide](https://pipedrive.readme.io/docs/pipedrive-api-v2-migration-guide)).
  Each entity exposes the identical shape:

  - `GET /api/v2/{entity}/:id/followers` — cursor-paginated list
  - `POST /api/v2/{entity}/:id/followers` — add (`user_id` body param)
  - `DELETE /api/v2/{entity}/:id/followers/:follower_id` — remove

  `list_page/4` and `add/4` / `delete/4` take an `entity` atom
  (`:deal`, `:person`, or `:organization`); per-entity convenience wrappers
  (`list_deal_followers/3`, `add_person_follower/3`, …) are provided below.

  ## Example

      {:ok, page} = ExPipedrive.Followers.list_deal_followers(client, deal_id)
      {:ok, follower} = ExPipedrive.Followers.add_deal_follower(client, deal_id, user_id)
      {:ok, _} = ExPipedrive.Followers.delete_deal_follower(client, deal_id, follower.id)
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.Error
  alias ExPipedrive.Follower
  alias ExPipedrive.Page
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  @type entity :: :deal | :person | :organization

  @doc """
  Lists one cursor page of followers via `GET /api/v2/{entity}/:id/followers`.

  Options: `:cursor`, `:limit` (clamped to `ExPipedrive.Cursor.max_limit/0`).
  """
  @spec list_page(Client.t(), entity(), term(), keyword()) ::
          {:ok, Page.t()} | {:error, Error.t()}
  def list_page(%Client{} = client, entity, entity_id, opts \\ []) when is_atom(entity) do
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))
    query = [limit: limit] |> maybe_put(:cursor, Keyword.get(opts, :cursor))

    client
    |> Request.get("#{segment(entity)}/:id/followers",
      query: query,
      opts: [path_params: [id: entity_id]]
    )
    |> Response.map([200], fn %{body: body} ->
      items = body |> Map.get("data") |> List.wrap() |> Enum.map(&Follower.new/1)
      Page.from_items(items, body)
    end)
  end

  @doc """
  Lazily streams followers across all cursor pages. See `Cursor.stream/2`.
  """
  @spec stream(Client.t(), entity(), term(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, entity, entity_id, opts \\ []) when is_atom(entity) do
    Cursor.stream(
      fn page_opts -> list_page(client, entity, entity_id, Keyword.merge(opts, page_opts)) end,
      opts
    )
  end

  @doc """
  Adds a user as a follower via `POST /api/v2/{entity}/:id/followers`.
  """
  @spec add(Client.t(), entity(), term(), pos_integer()) ::
          {:ok, Follower.t()} | {:error, Error.t()}
  def add(%Client{} = client, entity, entity_id, user_id) when is_atom(entity) do
    client
    |> Request.post("#{segment(entity)}/:id/followers", %{"user_id" => user_id},
      opts: [path_params: [id: entity_id]]
    )
    |> Response.map([200, 201], fn %{body: %{"data" => data}} -> Follower.new(data) end)
  end

  @doc """
  Removes a follower via `DELETE /api/v2/{entity}/:id/followers/:follower_id`.
  """
  @spec delete(Client.t(), entity(), term(), term()) ::
          {:ok, Follower.t()} | {:error, Error.t()}
  def delete(%Client{} = client, entity, entity_id, follower_id) when is_atom(entity) do
    client
    |> Request.delete("#{segment(entity)}/:id/followers/:follower_id",
      opts: [path_params: [id: entity_id, follower_id: follower_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} -> Follower.new(data) end)
  end

  @doc "Lists followers of a deal. See `list_page/4`."
  @spec list_deal_followers(Client.t(), term(), keyword()) ::
          {:ok, Page.t()} | {:error, Error.t()}
  def list_deal_followers(%Client{} = client, deal_id, opts \\ []),
    do: list_page(client, :deal, deal_id, opts)

  @doc "Streams followers of a deal. See `stream/4`."
  @spec stream_deal_followers(Client.t(), term(), keyword()) :: Enumerable.t()
  def stream_deal_followers(%Client{} = client, deal_id, opts \\ []),
    do: stream(client, :deal, deal_id, opts)

  @doc "Adds a follower to a deal. See `add/4`."
  @spec add_deal_follower(Client.t(), term(), pos_integer()) ::
          {:ok, Follower.t()} | {:error, Error.t()}
  def add_deal_follower(%Client{} = client, deal_id, user_id),
    do: add(client, :deal, deal_id, user_id)

  @doc "Removes a follower from a deal. See `delete/4`."
  @spec delete_deal_follower(Client.t(), term(), term()) ::
          {:ok, Follower.t()} | {:error, Error.t()}
  def delete_deal_follower(%Client{} = client, deal_id, follower_id),
    do: delete(client, :deal, deal_id, follower_id)

  @doc "Lists followers of a person. See `list_page/4`."
  @spec list_person_followers(Client.t(), term(), keyword()) ::
          {:ok, Page.t()} | {:error, Error.t()}
  def list_person_followers(%Client{} = client, person_id, opts \\ []),
    do: list_page(client, :person, person_id, opts)

  @doc "Streams followers of a person. See `stream/4`."
  @spec stream_person_followers(Client.t(), term(), keyword()) :: Enumerable.t()
  def stream_person_followers(%Client{} = client, person_id, opts \\ []),
    do: stream(client, :person, person_id, opts)

  @doc "Adds a follower to a person. See `add/4`."
  @spec add_person_follower(Client.t(), term(), pos_integer()) ::
          {:ok, Follower.t()} | {:error, Error.t()}
  def add_person_follower(%Client{} = client, person_id, user_id),
    do: add(client, :person, person_id, user_id)

  @doc "Removes a follower from a person. See `delete/4`."
  @spec delete_person_follower(Client.t(), term(), term()) ::
          {:ok, Follower.t()} | {:error, Error.t()}
  def delete_person_follower(%Client{} = client, person_id, follower_id),
    do: delete(client, :person, person_id, follower_id)

  @doc "Lists followers of an organization. See `list_page/4`."
  @spec list_organization_followers(Client.t(), term(), keyword()) ::
          {:ok, Page.t()} | {:error, Error.t()}
  def list_organization_followers(%Client{} = client, org_id, opts \\ []),
    do: list_page(client, :organization, org_id, opts)

  @doc "Streams followers of an organization. See `stream/4`."
  @spec stream_organization_followers(Client.t(), term(), keyword()) :: Enumerable.t()
  def stream_organization_followers(%Client{} = client, org_id, opts \\ []),
    do: stream(client, :organization, org_id, opts)

  @doc "Adds a follower to an organization. See `add/4`."
  @spec add_organization_follower(Client.t(), term(), pos_integer()) ::
          {:ok, Follower.t()} | {:error, Error.t()}
  def add_organization_follower(%Client{} = client, org_id, user_id),
    do: add(client, :organization, org_id, user_id)

  @doc "Removes a follower from an organization. See `delete/4`."
  @spec delete_organization_follower(Client.t(), term(), term()) ::
          {:ok, Follower.t()} | {:error, Error.t()}
  def delete_organization_follower(%Client{} = client, org_id, follower_id),
    do: delete(client, :organization, org_id, follower_id)

  defp segment(:deal), do: "deals"
  defp segment(:person), do: "persons"
  defp segment(:organization), do: "organizations"

  defp maybe_put(query, _key, nil), do: query
  defp maybe_put(query, key, value), do: Keyword.put(query, key, value)
end
