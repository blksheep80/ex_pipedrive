defmodule ExPipedrive.Pipelines do
  @moduledoc """
  Pipedrive pipelines resource.

  v2-first helpers (`get/2`, `create/2`, `update/3`, `delete/2`, `list_page/2`,
  `stream/2`) talk to `/api/v2/pipelines` via `ExPipedrive.Resource`. Legacy
  `list_pipelines/1` and `list_pipeline_deals/2` remain on API v1 — prefer
  `list_page/2` / `stream/2` for new code (`list_pipelines/1` returns a bare
  `{:ok, list}`).

  For deals in a pipeline on v2, prefer `ExPipedrive.Deals.list_page/2` or
  `stream/2` with `pipeline_id:` — Pipedrive deprecated
  `GET /pipelines/:id/deals`.
  """

  @behaviour ExPipedrive.Resource

  alias ExPipedrive.Deal
  alias ExPipedrive.Pipeline
  alias ExPipedrive.Request
  alias ExPipedrive.Resource
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(name is_deal_probability_enabled)

  @impl true
  def path, do: "pipelines"

  @impl true
  def decode(data) when is_map(data), do: Pipeline.new(data)

  @impl true
  def encode(attrs), do: WriteAttrs.take(attrs, @write_fields)

  @impl true
  def list_query_keys, do: [:sort_by, :sort_direction]

  # --- API v2 ---

  @doc """
  Fetches a pipeline by id via `GET /api/v2/pipelines/:id`.
  """
  def get(%Client{} = client, pipeline_id) do
    Resource.get(__MODULE__, client, pipeline_id)
  end

  @doc """
  Creates a pipeline via `POST /api/v2/pipelines`.

  Accepts a map (preferred) or `%Pipeline{}`. Returns `{:ok, %Pipeline{}}`.
  """
  def create(%Client{} = client, attrs) do
    Resource.create(__MODULE__, client, attrs)
  end

  @doc """
  Updates a pipeline via `PATCH /api/v2/pipelines/:id`.
  """
  def update(%Client{} = client, pipeline_id, attrs) do
    Resource.update(__MODULE__, client, pipeline_id, attrs)
  end

  @doc """
  Deletes a pipeline via `DELETE /api/v2/pipelines/:id`.
  """
  def delete(%Client{} = client, pipeline_id) do
    Resource.delete(__MODULE__, client, pipeline_id)
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
    Resource.list_page(__MODULE__, client, opts)
  end

  def stream_pipelines(%Client{} = client, opts \\ []) do
    Resource.stream(__MODULE__, client, opts)
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
