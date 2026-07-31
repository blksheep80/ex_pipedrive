defmodule ExPipedrive.Tasks do
  @moduledoc """
  Pipedrive tasks resource — action items associated with projects.

  API v2 only (OpenAPI tag **Tasks**, beta). Supports cursor-paginated list,
  get, create, update, and delete against `/api/v2/tasks`.

  ## Example

      {:ok, page} = ExPipedrive.Tasks.list_page(client, project_id: 1)
      {:ok, task} = ExPipedrive.Tasks.get(client, 1)

      {:ok, task} =
        ExPipedrive.Tasks.create(client, %{
          title: "Ship v0.3",
          project_id: 1,
          assignee_ids: [2]
        })

      {:ok, task} = ExPipedrive.Tasks.update(client, task.id, %{done: 1})
      {:ok, :ok} = ExPipedrive.Tasks.delete(client, task.id)
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.Error
  alias ExPipedrive.Page
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.Task
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    title project_id parent_task_id description done milestone due_date start_date
    assignee_id assignee_ids priority
  )

  @list_params ~w(
    cursor limit is_done is_milestone assignee_id project_id parent_task_id
  )a

  @doc """
  Lists one page of tasks via `GET /api/v2/tasks`.

  Options: `:cursor`, `:limit` (clamped to 500), `:is_done`, `:is_milestone`,
  `:assignee_id`, `:project_id`, and `:parent_task_id`.
  """
  @spec list_page(Client.t(), keyword()) :: {:ok, Page.t()} | {:error, Error.t()}
  def list_page(%Client{} = client, opts \\ []) do
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))

    query =
      opts
      |> Keyword.take(@list_params)
      |> Keyword.put(:limit, limit)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)

    client
    |> Request.get("tasks", query: query)
    |> Response.map([200], fn %{body: body} ->
      items = body |> Map.get("data") |> List.wrap() |> Enum.map(&Task.new/1)
      Page.from_items(items, body)
    end)
  end

  @doc """
  Lazily streams tasks across v2 cursor pages.
  """
  @spec stream(Client.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, opts \\ []) do
    Cursor.stream(
      fn page_opts -> list_page(client, Keyword.merge(opts, page_opts)) end,
      opts
    )
  end

  @doc """
  Fetches a task by id via `GET /api/v2/tasks/:id`.
  """
  @spec get(Client.t(), term()) :: {:ok, Task.t()} | {:error, Error.t()}
  def get(%Client{} = client, task_id) do
    client
    |> Request.get("tasks/:id", opts: [path_params: [id: task_id]])
    |> Response.map([200], fn %{body: %{"data" => data}} -> Task.new(data) end)
  end

  @doc """
  Creates a task via `POST /api/v2/tasks`.

  Requires `:title` and `:project_id`. Returns `{:ok, %Task{}}`.
  """
  @spec create(Client.t(), map()) :: {:ok, Task.t()} | {:error, Error.t()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    client
    |> Request.post("tasks", WriteAttrs.take(attrs, @write_fields))
    |> Response.map([200, 201], fn %{body: %{"data" => data}} -> Task.new(data) end)
  end

  @doc """
  Updates a task via `PATCH /api/v2/tasks/:id`.
  """
  @spec update(Client.t(), term(), map()) :: {:ok, Task.t()} | {:error, Error.t()}
  def update(%Client{} = client, task_id, attrs) when is_map(attrs) do
    client
    |> Request.patch("tasks/:id", WriteAttrs.take(attrs, @write_fields),
      opts: [path_params: [id: task_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} -> Task.new(data) end)
  end

  @doc """
  Marks a task as deleted via `DELETE /api/v2/tasks/:id`.

  Returns `{:ok, :ok}`.
  """
  @spec delete(Client.t(), term()) :: {:ok, :ok} | {:error, Error.t()}
  def delete(%Client{} = client, task_id) do
    client
    |> Request.delete("tasks/:id", opts: [path_params: [id: task_id]])
    |> Response.map([200], fn _env -> :ok end)
  end
end
