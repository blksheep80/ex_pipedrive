defmodule ExPipedrive.Persons do
  @moduledoc """
  Pipedrive persons resource.

  v2-first helpers (`get/2`, `create/2`, `update/3`, `list_page/2`, `stream/2`)
  talk to `/api/v2/persons` via `ExPipedrive.Resource`. Prefer
  `ExPipedrive.Search.search_persons/3` (or `search_v2/3` here) for v2
  itemSearch. Legacy `get_person/2`, `create_person/2`, `list_persons/2`, and
  `search_persons/3` remain on API v1.

  Persons have no v2 delete in this client (intentional; use Raw if needed).
  """

  @behaviour ExPipedrive.Resource

  alias ExPipedrive.PagedResult
  alias ExPipedrive.Person
  alias ExPipedrive.Request
  alias ExPipedrive.Resource
  alias ExPipedrive.Response
  alias ExPipedrive.Search
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    name owner_id org_id emails phones visible_to label_ids custom_fields
  )

  @impl true
  def path, do: "persons"

  @impl true
  def decode(data) when is_map(data), do: Person.new(data)

  @impl true
  def encode(attrs), do: WriteAttrs.take(attrs, @write_fields)

  @impl true
  def list_query_keys, do: [:owner_id, :org_id]

  # --- API v2 ---

  @doc """
  Fetches a person by id via `GET /api/v2/persons/:id`.
  """
  def get(%Client{} = client, person_id) do
    Resource.get(__MODULE__, client, person_id)
  end

  @doc """
  Creates a person via `POST /api/v2/persons`.

  Accepts a map (preferred) or `%Person{}`. For v2, email/phone values belong
  under `emails` / `phones` lists.
  """
  def create(%Client{} = client, attrs) do
    Resource.create(__MODULE__, client, attrs, success_statuses: [201])
  end

  @doc """
  Updates a person via `PATCH /api/v2/persons/:id`.
  """
  def update(%Client{} = client, person_id, attrs) do
    Resource.update(__MODULE__, client, person_id, attrs)
  end

  def list_page(%Client{} = client, opts \\ []), do: list_persons_page(client, opts)

  def stream(%Client{} = client, opts \\ []), do: stream_persons(client, opts)

  def list_persons_page(%Client{} = client, opts \\ []) do
    Resource.list_page(__MODULE__, client, opts)
  end

  def stream_persons(%Client{} = client, opts \\ []) do
    Resource.stream(__MODULE__, client, opts)
  end

  # --- API v1 (legacy) ---

  def get_person(%Client{} = client, id) do
    client
    |> Request.get("persons/:id", api_version: :v1, opts: [path_params: [id: id]])
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      Person.new(data)
    end)
  end

  def create_person(%Client{} = client, %Person{} = person) do
    client
    |> Request.post("persons", person, api_version: :v1)
    |> Response.map([201], fn %{body: %{"data" => person_data}} ->
      Person.new(person_data)
    end)
  end

  def list_persons(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("persons", api_version: :v1, query: [start: start, limit: limit])
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} ->
        PagedResult.new(Enum.map(data, &Person.new/1), body)
    end)
  end

  def search_persons(%Client{} = client, term, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("persons/search",
      api_version: :v1,
      query: [term: term, start: start, limit: limit]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      data
      |> Map.get("items")
      |> Enum.map(fn item_container ->
        Person.new_from_search(Map.get(item_container, "item"))
      end)
    end)
  end

  @doc """
  Searches persons via API v2 itemSearch. See `ExPipedrive.Search.search_persons/3`.
  """
  def search_v2(%Client{} = client, term, opts \\ []) do
    Search.search_persons(client, term, opts)
  end
end
