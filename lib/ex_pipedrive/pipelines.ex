defmodule ExPipedrive.Pipelines do
  @moduledoc """
  Pipedrive pipelines resource.

  v2-first helpers (`get/2`, `create/2`, `update/3`, `delete/2`, `list_page/2`,
  `stream/2`) talk to `/api/v2/pipelines`. Legacy `list_pipelines/1` and
  `list_pipeline_deals/2` remain on API v1 — prefer `list_page/2` / `stream/2`
  for new code (`list_pipelines/1` returns a bare `{:ok, list}`).

  For deals in a pipeline on v2, prefer `ExPipedrive.Deals.list_page/2` or
  `stream/2` with `pipeline_id:` — Pipedrive deprecated
  `GET /pipelines/:id/deals`.
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.Deal
  alias ExPipedrive.Page
  alias ExPipedrive.Pipeline
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(name is_deal_probability_enabled)

  # --- API v2 ---

  @doc """
  Fetches a pipeline by id via `GET /api/v2/pipelines/:id`.
  """
  def get(%Client{} = client, pipeline_id) do
    client
    |> Request.get("pipelines/:id", opts: [path_params: [id: pipeline_id]])
    |> Response.map([200], fn %{body: %{"data" => pipeline_data}} ->
      Pipeline.new(pipeline_data)
    end)
  end

  @doc """
  Creates a pipeline via `POST /api/v2/pipelines`.

  Accepts a map (preferred) or `%Pipeline{}`. Returns `{:ok, %Pipeline{}}`.
  """
  def create(%Client{} = client, attrs) do
    body = WriteAttrs.take(attrs, @write_fields)

    client
    |> Request.post("pipelines", body)
    |> Response.map([200, 201], fn %{body: %{"data" => pipeline_data}} ->
      Pipeline.new(pipeline_data)
    end)
  end

  @doc """
  Updates a pipeline via `PATCH /api/v2/pipelines/:id`.
  """
  def update(%Client{} = client, pipeline_id, attrs) do
    body = WriteAttrs.take(attrs, @write_fields)

    client
    |> Request.patch("pipelines/:id", body, opts: [path_params: [id: pipeline_id]])
    |> Response.map([200], fn %{body: %{"data" => pipeline_data}} ->
      Pipeline.new(pipeline_data)
    end)
  end

  @doc """
  Deletes a pipeline via `DELETE /api/v2/pipelines/:id`.
  """
  def delete(%Client{} = client, pipeline_id) do
    client
    |> Request.delete("pipelines/:id", opts: [path_params: [id: pipeline_id]])
    |> Response.map([200], fn %{body: body} -> body end)
  end

  @doc """
  Lists one page of pipelines via API v2 cursor pagination.

  Options: `:cursor`, `:limit` (clamped to 500), `:sort_by`, `:sort_direction`.
  """
  def list_page(%Client{} = client, opts \\ []) do
    list_pipelines_page(client, opts)
  end

  @doc """
  Lazily streams pipelines across all v2 cursor pages until `next_cursor` is nil.
  """
  def stream(%Client{} = client, opts \\ []) do
    stream_pipelines(client, opts)
  end

  def list_pipelines_page(%Client{} = client, opts \\ []) do
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))

    query =
      opts
      |> Keyword.take([:cursor, :sort_by, :sort_direction])
      |> Keyword.put(:limit, limit)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    client
    |> Request.get("pipelines", query: query)
    |> Response.map([200], fn %{body: body} ->
      items =
        body
        |> Map.get("data")
        |> List.wrap()
        |> Enum.map(&Pipeline.new/1)

      Page.from_items(items, body)
    end)
  end

  def stream_pipelines(%Client{} = client, opts \\ []) do
    Cursor.stream(
      fn page_opts ->
        list_pipelines_page(client, Keyword.merge(opts, page_opts))
      end,
      opts
    )
  end

  # --- API v1 (legacy) ---

  @doc """
  Lists all pipelines via API v1 `GET /pipelines`.

  Soft-deprecated: prefer `list_page/2` or `stream/2` (API v2, `{:ok, %Page{}}`
  / lazy stream). This helper returns `{:ok, [%Pipeline{}]}` with no pagination
  metadata.
  """
  def list_pipelines(%Client{} = client) do
    client
    |> Request.get("pipelines", api_version: :v1)
    |> Response.map([200], fn %{body: %{"data" => pipeline_data}} ->
      Enum.map(pipeline_data, &Pipeline.new/1)
    end)
  end

  @doc """
  Lists deals in a pipeline via deprecated v1 `GET /pipelines/:id/deals`.

  Prefer `ExPipedrive.Deals.list_page(client, pipeline_id: id)` on API v2.
  """
  def list_pipeline_deals(%Client{} = client, pipeline_id) do
    client
    |> Request.get("pipelines/:id/deals",
      api_version: :v1,
      opts: [path_params: [id: pipeline_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => deal_data}} ->
      Enum.map(deal_data, &Deal.new/1)
    end)
  end
end
