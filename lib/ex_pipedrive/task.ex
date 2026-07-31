defmodule ExPipedrive.Task do
  @moduledoc """
  A project task decoded from Pipedrive API v2 `/api/v2/tasks` responses.

  Tasks are action items associated with a project. Write requests use `done`
  and `milestone` (0/1); responses expose `is_done` and `is_milestone`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :title, String.t(), enforce: true
    field :creator_id, pos_integer()
    field :description, String.t()
    field :project_id, pos_integer()
    field :is_done, boolean()
    field :is_milestone, boolean()
    field :due_date, Date.t()
    field :start_date, Date.t()
    field :parent_task_id, pos_integer()
    field :assignee_ids, list(pos_integer()), default: []
    field :priority, integer()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :update_time, DateTime.t() | NaiveDateTime.t()
    field :marked_as_done_time, DateTime.t() | NaiveDateTime.t()
    field :original_object, map()
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:project_id, nil, &normalize_id/1)
    |> Map.update(:creator_id, nil, &normalize_id/1)
    |> Map.update(:parent_task_id, nil, &normalize_id/1)
    |> Map.update(:due_date, nil, &parse_date/1)
    |> Map.update(:start_date, nil, &parse_date/1)
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.update(:marked_as_done_time, nil, &parse_datetime/1)
    |> Map.put(:original_object, original)
  end
end
