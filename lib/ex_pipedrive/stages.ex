defmodule ExPipedrive.Stages do
  @moduledoc """
  Pipedrive stages resource.

  v2-first helpers (`get/2`, `create/2`, `update/3`, `delete/2`, `list_page/2`,
  `stream/2`) talk to `/api/v2/stages` via `ExPipedrive.Resource`.
  """

  @behaviour ExPipedrive.Resource

  alias ExPipedrive.Resource
  alias ExPipedrive.Stage
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    name pipeline_id deal_probability is_deal_rot_enabled days_to_rotten
  )

  @impl true
  def path, do: "stages"

  @impl true
  def decode(data) when is_map(data), do: Stage.new(data)

  @impl true
  def encode(attrs), do: WriteAttrs.take(attrs, @write_fields)

  @impl true
  def list_query_keys, do: [:pipeline_id, :sort_by, :sort_direction]

  @doc """
  Fetches a stage by id via `GET /api/v2/stages/:id`.
  """
  def get(%Client{} = client, stage_id) do
    Resource.get(__MODULE__, client, stage_id)
  end

  @doc """
  Creates a stage via `POST /api/v2/stages`.

  Accepts a map (preferred) or `%Stage{}`. Returns `{:ok, %Stage{}}`.
  """
  def create(%Client{} = client, attrs) do
    Resource.create(__MODULE__, client, attrs)
  end

  @doc """
  Updates a stage via `PATCH /api/v2/stages/:id`.
  """
  def update(%Client{} = client, stage_id, attrs) do
    Resource.update(__MODULE__, client, stage_id, attrs)
  end

  @doc """
  Deletes a stage via `DELETE /api/v2/stages/:id`.
  """
  def delete(%Client{} = client, stage_id) do
    Resource.delete(__MODULE__, client, stage_id)
  end

  @doc """
  Lists one page of stages via API v2 cursor pagination.

  Options: `:cursor`, `:limit` (clamped to 500), `:pipeline_id`, `:sort_by`,
  `:sort_direction`.
  """
  def list_page(%Client{} = client, opts \\ []) do
    list_stages_page(client, opts)
  end

  @doc """
  Lazily streams stages across all v2 cursor pages until `next_cursor` is nil.
  """
  def stream(%Client{} = client, opts \\ []) do
    stream_stages(client, opts)
  end

  def list_stages_page(%Client{} = client, opts \\ []) do
    Resource.list_page(__MODULE__, client, opts)
  end

  def stream_stages(%Client{} = client, opts \\ []) do
    Resource.stream(__MODULE__, client, opts)
  end
end
