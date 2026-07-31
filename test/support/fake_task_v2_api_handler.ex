defmodule ExPipedrive.FakeTaskV2ApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V2Tasks

  def handle_list_tasks_v2(conn, params) do
    json_ok(conn, V2Tasks.list_response(Map.get(params, "cursor")))
  end

  def handle_get_task_v2(conn, %{"id" => "404"}) do
    json_error(conn, 404, "Task not found")
  end

  def handle_get_task_v2(conn, %{"id" => id}) do
    case Integer.parse(id) do
      {int, ""} -> json_ok(conn, V2Tasks.get_response(int))
      _ -> json_error(conn, 400, "invalid task id")
    end
  end

  def handle_create_task_v2(%{body_params: body} = conn) do
    conn
    |> put_status(201)
    |> json_ok(V2Tasks.create_response(body))
  end

  def handle_update_task_v2(%{body_params: body, params: %{"id" => id}} = conn) do
    case id do
      "404" ->
        json_error(conn, 404, "Task not found")

      _ ->
        {int, ""} = Integer.parse(id)
        json_ok(conn, V2Tasks.update_response(int, body))
    end
  end

  def handle_delete_task_v2(conn, %{"id" => "404"}) do
    json_error(conn, 404, "Task not found")
  end

  def handle_delete_task_v2(conn, %{"id" => id}) do
    case Integer.parse(id) do
      {int, ""} -> json_ok(conn, V2Tasks.delete_response(int))
      _ -> json_error(conn, 400, "invalid task id")
    end
  end

  defp json_ok(conn, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> put_resp_header("x-request-id", "fake-task-v2")
    |> send_resp(conn.status || 200, Jason.encode!(body))
  end

  defp json_error(conn, status, message) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> put_resp_header("x-request-id", "fake-task-v2-error")
    |> send_resp(status, Jason.encode!(V2Tasks.error_response(status, message)))
  end
end
