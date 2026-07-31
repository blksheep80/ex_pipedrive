defmodule ExPipedrive.Goals do
  @moduledoc """
  API v1 client for Pipedrive goals.

  Sales goals (company, team, or user) live only on `/api/v1/goals`; there is
  no `/api/v2` equivalent. Every function here explicitly routes to
  `api_version: :v1`.

  Pipedrive's goals API has no plain "get by id" endpoint — only find
  (`list/2`, with optional filters), `create/2`, `update/3`, `delete/2`, and
  `get_result/4` (a goal's progress for a period) are supported.

  Unlike most Pipedrive entities, goal ids are Pipedrive-generated hex
  strings (e.g. `"5665cef556ddff22606fc8f6c0004807"`), not integers.

  `:type`, `:assignee`, `:expected_outcome`, and `:duration` are accepted (and
  decoded) as plain maps matching Pipedrive's nested JSON shape:

      %{
        title: "Some example goal",
        assignee: %{"id" => 123_456, "type" => "company"},
        type: %{"name" => "deals_started", "params" => %{"pipeline_id" => [5, 2]}},
        expected_outcome: %{"target" => 100, "tracking_metric" => "quantity"},
        duration: %{"start" => "2019-11-01", "end" => "2020-10-30"},
        interval: "weekly"
      }

  ## Example

      {:ok, goal} = ExPipedrive.Goals.create(client, attrs)
      {:ok, [goal]} = ExPipedrive.Goals.list(client, title: "Some example goal")
      {:ok, goal} = ExPipedrive.Goals.update(client, goal.id, %{title: "Renamed"})

      {:ok, %{progress: 42, goal: goal}} =
        ExPipedrive.Goals.get_result(client, goal.id, ~D[2020-01-01], ~D[2020-01-31])

      {:ok, :ok} = ExPipedrive.Goals.delete(client, goal.id)
  """

  alias ExPipedrive.Error
  alias ExPipedrive.Goal
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(title assignee type expected_outcome duration interval)

  @find_query_params [
    type_name: "type.name",
    title: "title",
    is_active: "is_active",
    assignee_id: "assignee.id",
    assignee_type: "assignee.type",
    expected_outcome_target: "expected_outcome.target",
    expected_outcome_tracking_metric: "expected_outcome.tracking_metric",
    expected_outcome_currency_id: "expected_outcome.currency_id",
    pipeline_id: "type.params.pipeline_id",
    stage_id: "type.params.stage_id",
    activity_type_id: "type.params.activity_type_id",
    period_start: "period.start",
    period_end: "period.end"
  ]

  @doc """
  Finds goals via `GET /api/v1/goals/find`.

  Accepts filter options matching Pipedrive's dot-notation search fields:
  `:type_name`, `:title`, `:is_active` (server defaults to `true` when
  omitted), `:assignee_id`, `:assignee_type`, `:expected_outcome_target`,
  `:expected_outcome_tracking_metric`, `:expected_outcome_currency_id`,
  `:pipeline_id`, `:stage_id`, `:activity_type_id`, `:period_start`, and
  `:period_end` (the latter two must be given together).

  Returns `{:ok, [%Goal{}]}`.
  """
  @spec list(Client.t(), keyword()) :: {:ok, [Goal.t()]} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    query =
      for {key, param} <- @find_query_params,
          {:ok, value} <- [Keyword.fetch(opts, key)],
          do: {param, value}

    client
    |> Request.get("goals/find", api_version: :v1, query: query)
    |> Response.map([200], fn
      %{body: %{"data" => nil}} -> []
      %{body: %{"data" => %{"goals" => goals}}} -> Enum.map(goals || [], &Goal.new/1)
    end)
  end

  @doc """
  Creates a goal via `POST /api/v1/goals`.

  Pipedrive requires `:type`, `:assignee`, `:expected_outcome`, `:duration`,
  and `:interval`; `:title` is optional. Returns `{:ok, %Goal{}}`.
  """
  @spec create(Client.t(), map()) :: {:ok, Goal.t()} | {:error, Error.t()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    client
    |> Request.post("goals", WriteAttrs.take(attrs, @write_fields), api_version: :v1)
    |> Response.map([200, 201], fn %{body: %{"data" => %{"goal" => goal}}} -> Goal.new(goal) end)
  end

  @doc """
  Updates a goal via `PUT /api/v1/goals/:id`.

  Accepts a map of any of `:title`, `:assignee`, `:type`, `:expected_outcome`,
  `:duration`, `:interval`. Returns `{:ok, %Goal{}}`.
  """
  @spec update(Client.t(), String.t(), map()) :: {:ok, Goal.t()} | {:error, Error.t()}
  def update(%Client{} = client, goal_id, attrs) when is_map(attrs) do
    client
    |> Request.put(
      "goals/:id",
      WriteAttrs.take(attrs, @write_fields),
      api_version: :v1,
      opts: [path_params: [id: goal_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => %{"goal" => goal}}} -> Goal.new(goal) end)
  end

  @doc """
  Marks a goal as deleted via `DELETE /api/v1/goals/:id`.

  Returns `{:ok, :ok}`.
  """
  @spec delete(Client.t(), String.t()) :: {:ok, :ok} | {:error, Error.t()}
  def delete(%Client{} = client, goal_id) do
    client
    |> Request.delete("goals/:id", api_version: :v1, opts: [path_params: [id: goal_id]])
    |> Response.map([200], fn _env -> :ok end)
  end

  @doc """
  Gets a goal's progress for a period via `GET /api/v1/goals/:id/results`.

  `period_start` and `period_end` accept a `Date` or a `"YYYY-MM-DD"` string
  and must fall within the goal's own `duration`.

  Returns `{:ok, %{progress: integer(), goal: %Goal{}}}`.
  """
  @spec get_result(Client.t(), String.t(), Date.t() | String.t(), Date.t() | String.t()) ::
          {:ok, %{progress: integer(), goal: Goal.t()}} | {:error, Error.t()}
  def get_result(%Client{} = client, goal_id, period_start, period_end) do
    client
    |> Request.get(
      "goals/:id/results",
      api_version: :v1,
      opts: [path_params: [id: goal_id]],
      query: [
        {"period.start", to_date_param(period_start)},
        {"period.end", to_date_param(period_end)}
      ]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} ->
      %{progress: Map.get(data, "progress"), goal: Goal.new(Map.get(data, "goal"))}
    end)
  end

  defp to_date_param(%Date{} = date), do: Date.to_iso8601(date)
  defp to_date_param(value) when is_binary(value), do: value
end
