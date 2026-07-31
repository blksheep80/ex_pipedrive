defmodule ExPipedrive.ProjectBoards do
  @moduledoc """
  Pipedrive project boards resource — workflow containers for projects.

  v2 helpers talk to `/api/v2/boards` via `ExPipedrive.Resource`.
  Shapes follow [Pipedrive OpenAPI v2](https://developers.pipedrive.com/docs/api/v2/openapi.yaml).

  Phases within a board (`/api/v2/phases`) are not implemented here; see
  `ExPipedrive.Projects` moduledoc for other deferred project-cluster APIs.

  ## Example

      {:ok, boards} = ExPipedrive.ProjectBoards.list_page(client)
      {:ok, board} = ExPipedrive.ProjectBoards.get(client, 1)

      {:ok, board} =
        ExPipedrive.ProjectBoards.create(client, %{name: "Delivery board", order_nr: 1})

      {:ok, board} =
        ExPipedrive.ProjectBoards.update(client, board.id, %{name: "Renamed board"})

      {:ok, %{"data" => %{"id" => _}}} = ExPipedrive.ProjectBoards.delete(client, board.id)
  """

  @behaviour ExPipedrive.Resource

  alias ExPipedrive.ProjectBoard
  alias ExPipedrive.Resource
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(name order_nr)

  @impl true
  def path, do: "boards"

  @impl true
  def decode(data) when is_map(data), do: ProjectBoard.new(data)

  @impl true
  def encode(attrs), do: WriteAttrs.take(attrs, @write_fields)

  @doc """
  Fetches a project board by id via `GET /api/v2/boards/:id`.
  """
  def get(%Client{} = client, board_id) do
    Resource.get(__MODULE__, client, board_id)
  end

  @doc """
  Creates a project board via `POST /api/v2/boards`.

  Requires `:name`. Returns `{:ok, %ProjectBoard{}}`.
  """
  def create(%Client{} = client, attrs) when is_map(attrs) do
    Resource.create(__MODULE__, client, attrs, success_statuses: [200, 201])
  end

  @doc """
  Updates a project board via `PATCH /api/v2/boards/:id`.
  """
  def update(%Client{} = client, board_id, attrs) when is_map(attrs) do
    Resource.update(__MODULE__, client, board_id, attrs)
  end

  @doc """
  Deletes a project board via `DELETE /api/v2/boards/:id`.
  """
  def delete(%Client{} = client, board_id) do
    Resource.delete(__MODULE__, client, board_id)
  end

  @doc """
  Lists project boards via `GET /api/v2/boards`.

  Pipedrive returns all active boards in one response (no cursor in OpenAPI).
  `:cursor` and `:limit` are forwarded if supplied but may be ignored by the API.
  """
  def list_page(%Client{} = client, opts \\ []) do
    Resource.list_page(__MODULE__, client, opts)
  end

  @doc """
  Streams project boards. For the live API this is typically a single page.
  """
  def stream(%Client{} = client, opts \\ []) do
    Resource.stream(__MODULE__, client, opts)
  end
end
