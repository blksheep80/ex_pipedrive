defmodule ExPipedrive.Stages do
  @moduledoc """
  Pipedrive stages resource.

  v2-first helpers (`get/2`, `create/2`, `update/3`, `delete/2`, `list_page/2`,
  `stream/2`) talk to `/api/v2/stages`.
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.Page
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.Stage
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    name pipeline_id deal_probability is_deal_rot_enabled days_to_rotten
  )

  @doc """
  Fetches a stage by id via `GET /api/v2/stages/:id`.
  """
  def get(%Client{} = client, stage_id) do
    client
    |> Request.get("stages/:id", opts: [path_params: [id: stage_id]])
    |> Response.map([200], fn %{body: %{"data" => stage_data}} ->
      Stage.new(stage_data)
    end)
  end

  @doc """
  Creates a stage via `POST /api/v2/stages`.

  Accepts a map (preferred) or `%Stage{}`. Returns `{:ok, %Stage{}}`.
  """
  def create(%Client{} = client, attrs) do
    body = WriteAttrs.take(attrs, @write_fields)

    client
    |> Request.post("stages", body)
    |> Response.map([200, 201], fn %{body: %{"data" => stage_data}} ->
      Stage.new(stage_data)
    end)
  end

  @doc """
  Updates a stage via `PATCH /api/v2/stages/:id`.
  """
  def update(%Client{} = client, stage_id, attrs) do
    body = WriteAttrs.take(attrs, @write_fields)

    client
    |> Request.patch("stages/:id", body, opts: [path_params: [id: stage_id]])
    |> Response.map([200], fn %{body: %{"data" => stage_data}} ->
      Stage.new(stage_data)
    end)
  end

  @doc """
  Deletes a stage via `DELETE /api/v2/stages/:id`.
  """
  def delete(%Client{} = client, stage_id) do
    client
    |> Request.delete("stages/:id", opts: [path_params: [id: stage_id]])
    |> Response.map([200], fn %{body: body} -> body end)
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
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))

    query =
      opts
      |> Keyword.take([:cursor, :pipeline_id, :sort_by, :sort_direction])
      |> Keyword.put(:limit, limit)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    client
    |> Request.get("stages", query: query)
    |> Response.map([200], fn %{body: body} ->
      items =
        body
        |> Map.get("data")
        |> List.wrap()
        |> Enum.map(&Stage.new/1)

      Page.from_items(items, body)
    end)
  end

  def stream_stages(%Client{} = client, opts \\ []) do
    Cursor.stream(
      fn page_opts ->
        list_stages_page(client, Keyword.merge(opts, page_opts))
      end,
      opts
    )
  end
end
