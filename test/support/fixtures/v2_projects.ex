defmodule ExPipedrive.Fixtures.V2Projects do
  @moduledoc false

  def project(id \\ 3, overrides \\ %{}) do
    Map.merge(
      %{
        "id" => id,
        "title" => "Project",
        "description" => "Description",
        "status" => "open",
        "board_id" => 1,
        "phase_id" => 1,
        "owner_id" => 1,
        "start_date" => "2026-04-15",
        "end_date" => "2026-04-23",
        "deal_ids" => [1],
        "person_ids" => [1],
        "org_ids" => [1],
        "label_ids" => [1],
        "health_status" => 10,
        "add_time" => "2026-04-14T10:45:20.852Z",
        "update_time" => "2026-04-14T10:45:20.852Z",
        "status_change_time" => "2026-04-14T10:45:20.852Z",
        "archive_time" => nil,
        "custom_fields" => %{}
      },
      overrides
    )
  end

  def archived_project(id \\ 7) do
    project(id, %{
      "title" => "Archived project",
      "status" => "completed",
      "archive_time" => "2026-05-01T12:00:00.000Z"
    })
  end

  def get_response(id \\ 3) do
    %{"success" => true, "data" => project(id)}
  end

  def list_response(cursor \\ nil) do
    {data, next_cursor} =
      case cursor do
        nil -> {[project(3), project(4, %{"title" => "Second project"})], "projects-page-2"}
        "projects-page-2" -> {[project(5, %{"title" => "Third project"})], nil}
        _ -> {[], nil}
      end

    %{
      "success" => true,
      "data" => data,
      "additional_data" => %{"next_cursor" => next_cursor}
    }
  end

  def archived_list_response(cursor \\ nil) do
    {data, next_cursor} =
      case cursor do
        nil -> {[archived_project(7)], nil}
        _ -> {[], nil}
      end

    %{
      "success" => true,
      "data" => data,
      "additional_data" => %{"next_cursor" => next_cursor}
    }
  end

  def create_response(attrs) when is_map(attrs) do
    base = project(99)

    data =
      Map.merge(base, %{
        "title" => Map.get(attrs, "title", base["title"]),
        "board_id" => Map.get(attrs, "board_id", base["board_id"]),
        "phase_id" => Map.get(attrs, "phase_id", base["phase_id"])
      })

    %{"success" => true, "data" => data}
  end

  def update_response(id, attrs) when is_map(attrs) do
    %{"success" => true, "data" => Map.merge(project(id), attrs)}
  end

  def delete_response(id) do
    %{"success" => true, "data" => %{"id" => id}}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-project-v2-#{status}"}
  end
end
