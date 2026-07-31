defmodule ExPipedrive.Fixtures.V2Tasks do
  @moduledoc false

  def task(id \\ 1) do
    %{
      "id" => id,
      "title" => "Task #{id}",
      "creator_id" => 2,
      "description" => "Task description",
      "project_id" => 1,
      "is_done" => false,
      "is_milestone" => false,
      "due_date" => "2026-10-11",
      "start_date" => "2026-09-01",
      "parent_task_id" => nil,
      "assignee_ids" => [2, 3],
      "priority" => nil,
      "add_time" => "2026-09-14T08:14:40.000Z",
      "update_time" => "2026-09-14T08:14:40.000Z",
      "marked_as_done_time" => nil
    }
  end

  def get_response(id \\ 1) do
    %{"success" => true, "data" => task(id)}
  end

  def list_response(cursor \\ nil) do
    {data, next_cursor} =
      case cursor do
        nil -> {[task(1), task(2)], "tasks-page-2"}
        "tasks-page-2" -> {[task(3)], nil}
        _ -> {[], nil}
      end

    %{
      "success" => true,
      "data" => data,
      "additional_data" => %{"next_cursor" => next_cursor}
    }
  end

  def create_response(attrs) when is_map(attrs) do
    data =
      task(99)
      |> Map.merge(
        Map.take(attrs, [
          "title",
          "project_id",
          "parent_task_id",
          "description",
          "due_date",
          "start_date",
          "assignee_ids",
          "priority"
        ])
      )
      |> apply_done_milestone(attrs)

    %{"success" => true, "data" => data}
  end

  def update_response(id, attrs) when is_map(attrs) do
    data =
      id
      |> task()
      |> Map.merge(
        Map.take(attrs, [
          "title",
          "project_id",
          "parent_task_id",
          "description",
          "due_date",
          "start_date",
          "assignee_ids",
          "priority"
        ])
      )
      |> apply_done_milestone(attrs)

    %{"success" => true, "data" => data}
  end

  def delete_response(id) do
    %{"success" => true, "data" => %{"id" => id}}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-#{status}"}
  end

  defp apply_done_milestone(data, attrs) do
    data
    |> maybe_put_bool("is_done", Map.get(attrs, "done"))
    |> maybe_put_bool("is_milestone", Map.get(attrs, "milestone"))
  end

  defp maybe_put_bool(data, _key, nil), do: data

  defp maybe_put_bool(data, key, 1), do: Map.put(data, key, true)
  defp maybe_put_bool(data, key, 0), do: Map.put(data, key, false)
  defp maybe_put_bool(data, key, value) when is_boolean(value), do: Map.put(data, key, value)
  defp maybe_put_bool(data, _key, _value), do: data
end
