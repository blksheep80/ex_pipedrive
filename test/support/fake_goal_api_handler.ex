defmodule ExPipedrive.FakeGoalApiHandler do
  @moduledoc false

  import Plug.Conn

  @goal_id "5665cef556ddff22606fc8f6c0004807"

  @goal %{
    "id" => @goal_id,
    "owner_id" => 987_654,
    "title" => "Some example goal",
    "type" => %{
      "name" => "Deals started",
      "params" => %{"pipeline_id" => [5, 2], "activity_type_id" => [9]}
    },
    "assignee" => %{"type" => "company", "id" => 123_456},
    "interval" => "weekly",
    "duration" => %{"start" => "2019-11-01", "end" => "2020-10-30"},
    "expected_outcome" => %{"target" => 100, "tracking_metric" => "quantity"},
    "is_active" => false,
    "report_ids" => ["f37bd66a2ab64d28ff6a9b6d2289813a"]
  }

  def handle_find_goals(conn, params) do
    data =
      case Map.get(params, "title") do
        "no match" -> []
        _ -> [@goal]
      end

    json(conn, 200, %{"success" => true, "data" => %{"goals" => data}})
  end

  def handle_create_goal(%{body_params: body} = conn) do
    goal = Map.merge(@goal, Map.take(body, Map.keys(@goal)))
    json(conn, 201, %{"success" => true, "data" => %{"goal" => goal}})
  end

  def handle_update_goal(%{body_params: body, params: %{"id" => @goal_id}} = conn) do
    goal = Map.merge(@goal, Map.take(body, Map.keys(@goal)))
    json(conn, 200, %{"success" => true, "data" => %{"goal" => goal}})
  end

  def handle_update_goal(%{params: %{"id" => "404"}} = conn) do
    json(conn, 404, %{"success" => false, "error" => "Goal not found"})
  end

  def handle_delete_goal(conn, %{"id" => @goal_id}) do
    json(conn, 200, %{"success" => true})
  end

  def handle_delete_goal(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Goal not found"})
  end

  def handle_get_goal_result(conn, %{"id" => @goal_id}) do
    json(conn, 200, %{"success" => true, "data" => %{"progress" => 42, "goal" => @goal}})
  end

  def handle_get_goal_result(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Goal not found"})
  end

  defp json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(status, Jason.encode!(body))
  end
end
