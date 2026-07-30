defmodule ExPipedrive.Organizations do
  @moduledoc """
  Pipedrive organizations resource.

  v2-first helpers (`get/2`, `create/2`, `update/3`, `delete/2`, `list_page/2`,
  `stream/2`) talk to `/api/v2/organizations`. Legacy `get_organization/2`,
  `create_organization/2`, `list_organizations/2`, `search_organizations/3`, and
  `update_organization/3` remain on API v1 for compatibility.
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.Organization
  alias ExPipedrive.Page
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    name owner_id visible_to label_ids address custom_fields
  )

  # --- API v2 ---

  @doc """
  Fetches an organization by id via `GET /api/v2/organizations/:id`.
  """
  def get(%Client{} = client, org_id) do
    client
    |> Request.get("organizations/:id", opts: [path_params: [id: org_id]])
    |> Response.map([200], fn %{body: %{"data" => org_data}} ->
      Organization.new(org_data)
    end)
  end

  @doc """
  Creates an organization via `POST /api/v2/organizations`.

  Accepts a map (preferred) or `%Organization{}`. Returns `{:ok, %Organization{}}`.
  """
  def create(%Client{} = client, attrs) do
    body = WriteAttrs.take(attrs, @write_fields)

    client
    |> Request.post("organizations", body)
    |> Response.map([201], fn %{body: %{"data" => org_data}} ->
      Organization.new(org_data)
    end)
  end

  @doc """
  Updates an organization via `PATCH /api/v2/organizations/:id`.
  """
  def update(%Client{} = client, org_id, attrs) do
    body = WriteAttrs.take(attrs, @write_fields)

    client
    |> Request.patch("organizations/:id", body, opts: [path_params: [id: org_id]])
    |> Response.map([200], fn %{body: %{"data" => org_data}} ->
      Organization.new(org_data)
    end)
  end

  @doc """
  Deletes an organization via `DELETE /api/v2/organizations/:id`.
  """
  def delete(%Client{} = client, org_id) do
    client
    |> Request.delete("organizations/:id", opts: [path_params: [id: org_id]])
    |> Response.map([200], fn %{body: body} -> body end)
  end

  @doc """
  Lists one page of organizations via API v2 cursor pagination.

  Options: `:cursor`, `:limit` (clamped to 500), `:owner_id`.
  """
  def list_page(%Client{} = client, opts \\ []) do
    list_organizations_page(client, opts)
  end

  @doc """
  Lazily streams organizations across all v2 cursor pages until `next_cursor` is nil.
  """
  def stream(%Client{} = client, opts \\ []) do
    stream_organizations(client, opts)
  end

  def list_organizations_page(%Client{} = client, opts \\ []) do
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))

    query =
      opts
      |> Keyword.take([:cursor, :owner_id])
      |> Keyword.put(:limit, limit)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    client
    |> Request.get("organizations", query: query)
    |> Response.map([200], fn %{body: body} ->
      items =
        body
        |> Map.get("data")
        |> List.wrap()
        |> Enum.map(&Organization.new/1)

      Page.from_items(items, body)
    end)
  end

  def stream_organizations(%Client{} = client, opts \\ []) do
    Cursor.stream(
      fn page_opts ->
        list_organizations_page(client, Keyword.merge(opts, page_opts))
      end,
      opts
    )
  end

  # --- API v1 (legacy) ---

  def get_organization(%Client{} = client, org_id) do
    client
    |> Request.get("organizations/:id", api_version: :v1, opts: [path_params: [id: org_id]])
    |> Response.map([200], fn %{body: %{"data" => org_data}} ->
      Organization.new(org_data)
    end)
  end

  def create_organization(%Client{} = client, %Organization{id: nil} = org) do
    client
    |> Request.post("organizations", org, api_version: :v1)
    |> Response.map([201], fn %{body: %{"data" => org_data}} ->
      Organization.new(org_data)
    end)
  end

  def list_organizations(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("organizations", api_version: :v1, query: [start: start, limit: limit])
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} ->
        PagedResult.new(Enum.map(data, &Organization.new/1), body)
    end)
  end

  def search_organizations(%Client{} = client, term, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("organizations/search",
      api_version: :v1,
      query: [term: term, start: start, limit: limit]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      data
      |> Map.get("items")
      |> Enum.map(fn item_container -> Organization.new(Map.get(item_container, "item")) end)
    end)
  end

  def update_organization(%Client{} = client, org_id, body) do
    client
    |> Request.put("organizations/:id", body,
      api_version: :v1,
      opts: [path_params: [id: org_id]]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      Organization.new(data)
    end)
  end
end
