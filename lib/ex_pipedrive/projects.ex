defmodule ExPipedrive.Projects do
  @moduledoc """
  Pipedrive projects resource — work items spanning deals, activities, and tasks.

  v2-first helpers talk to `/api/v2/projects` via `ExPipedrive.Resource`.
  Shapes follow [Pipedrive OpenAPI v2](https://developers.pipedrive.com/docs/api/v2/openapi.yaml).

  ## Implemented

  - `list_page/2`, `stream/2` — non-archived projects
  - `list_archived_page/2`, `stream_archived/2` — archived projects
  - `get/2`, `create/2`, `update/3`, `delete/2`

  ## Deferred (future issues / follow-ups)

  - `ExPipedrive.ProjectPhases` (`/api/v2/phases`)
  - `ExPipedrive.ProjectTemplates` (`/api/v2/projectTemplates`)
  - `ExPipedrive.ProjectFields` (`/api/v2/projectFields`)
  - Project search (`GET /api/v2/projects/search`)
  - Archive / unarchive (`POST /api/v2/projects/:id/archive`)
  - Permitted users and changelog sub-resources

  Project boards are available via `ExPipedrive.ProjectBoards`.

  ## Example

      {:ok, page} = ExPipedrive.Projects.list_page(client, status: "open")
      {:ok, project} = ExPipedrive.Projects.get(client, 3)

      {:ok, project} =
        ExPipedrive.Projects.create(client, %{
          title: "Office renovation",
          board_id: 1,
          phase_id: 1
        })

      {:ok, project} =
        ExPipedrive.Projects.update(client, project.id, %{status: "completed"})

      {:ok, %{"data" => %{"id" => _}}} = ExPipedrive.Projects.delete(client, project.id)
  """

  @behaviour ExPipedrive.Resource

  alias ExPipedrive.Cursor
  alias ExPipedrive.Error
  alias ExPipedrive.Page
  alias ExPipedrive.Project
  alias ExPipedrive.Request
  alias ExPipedrive.Resource
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    title description status board_id phase_id owner_id start_date end_date deal_ids
    person_ids org_ids label_ids health_status template_id custom_fields
  )

  @list_query_keys [
    :filter_id,
    :status,
    :phase_id,
    :deal_id,
    :person_id,
    :org_id
  ]

  @archived_list_query_keys [:filter_id, :status, :phase_id]

  @impl true
  def path, do: "projects"

  @impl true
  def decode(data) when is_map(data), do: Project.new(data)

  @impl true
  def encode(attrs), do: WriteAttrs.take(attrs, @write_fields)

  @impl true
  def list_query_keys, do: @list_query_keys

  @doc """
  Fetches a project by id via `GET /api/v2/projects/:id`.
  """
  @spec get(Client.t(), term()) :: {:ok, Project.t()} | {:error, Error.t()}
  def get(%Client{} = client, project_id) do
    Resource.get(__MODULE__, client, project_id)
  end

  @doc """
  Creates a project via `POST /api/v2/projects`.

  Requires `:title`. Returns `{:ok, %Project{}}`.
  """
  @spec create(Client.t(), map()) :: {:ok, Project.t()} | {:error, Error.t()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    Resource.create(__MODULE__, client, attrs, success_statuses: [201])
  end

  @doc """
  Updates a project via `PATCH /api/v2/projects/:id`.
  """
  @spec update(Client.t(), term(), map()) :: {:ok, Project.t()} | {:error, Error.t()}
  def update(%Client{} = client, project_id, attrs) when is_map(attrs) do
    Resource.update(__MODULE__, client, project_id, attrs)
  end

  @doc """
  Deletes a project via `DELETE /api/v2/projects/:id`.
  """
  @spec delete(Client.t(), term()) :: {:ok, term()} | {:error, Error.t()}
  def delete(%Client{} = client, project_id) do
    Resource.delete(__MODULE__, client, project_id)
  end

  @doc """
  Lists one page of non-archived projects via `GET /api/v2/projects`.

  Options: `:cursor`, `:limit` (clamped to 500), `:filter_id`, `:status`,
  `:phase_id`, `:deal_id`, `:person_id`, `:org_id`.
  """
  @spec list_page(Client.t(), keyword()) :: {:ok, Page.t()} | {:error, Error.t()}
  def list_page(%Client{} = client, opts \\ []) do
    Resource.list_page(__MODULE__, client, opts)
  end

  @doc """
  Lazily streams non-archived projects across v2 cursor pages.
  """
  @spec stream(Client.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, opts \\ []) do
    Resource.stream(__MODULE__, client, opts)
  end

  @doc """
  Lists one page of archived projects via `GET /api/v2/projects/archived`.

  Options: `:cursor`, `:limit` (clamped to 500), `:filter_id`, `:status`,
  `:phase_id`.
  """
  @spec list_archived_page(Client.t(), keyword()) :: {:ok, Page.t()} | {:error, Error.t()}
  def list_archived_page(%Client{} = client, opts \\ []) do
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))

    query =
      opts
      |> Keyword.take([:cursor | @archived_list_query_keys])
      |> Keyword.put(:limit, limit)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    client
    |> Request.get("projects/archived", query: query)
    |> Response.map([200], fn %{body: body} ->
      items =
        body
        |> Map.get("data")
        |> List.wrap()
        |> Enum.map(&Project.new/1)

      Page.from_items(items, body)
    end)
  end

  @doc """
  Lazily streams archived projects across v2 cursor pages.
  """
  @spec stream_archived(Client.t(), keyword()) :: Enumerable.t()
  def stream_archived(%Client{} = client, opts \\ []) do
    Cursor.stream(
      fn page_opts -> list_archived_page(client, Keyword.merge(opts, page_opts)) end,
      opts
    )
  end
end
