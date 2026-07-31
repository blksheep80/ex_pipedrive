defmodule ExPipedrive.FakeProjectBoardV2ApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V2ProjectBoards

  def handle_list_project_boards_v2(conn, _params) do
    json_ok(conn, V2ProjectBoards.list_response())
  end

  def handle_get_project_board_v2(conn, %{"id" => "404"}) do
    json_error(conn, 404, "Project board not found")
  end

  def handle_get_project_board_v2(conn, %{"id" => id}) do
    case Integer.parse(id) do
      {int, ""} -> json_ok(conn, V2ProjectBoards.get_response(int))
      _ -> json_error(conn, 400, "invalid board id")
    end
  end

  def handle_create_project_board_v2(%{body_params: body} = conn) do
    json_ok(conn, V2ProjectBoards.create_response(body))
  end

  def handle_update_project_board_v2(%{body_params: body, params: %{"id" => id}} = conn) do
    {int, ""} = Integer.parse(id)
    json_ok(conn, V2ProjectBoards.update_response(int, body))
  end

  def handle_delete_project_board_v2(conn, %{"id" => "404"}) do
    json_error(conn, 404, "Project board not found")
  end

  def handle_delete_project_board_v2(conn, %{"id" => id}) do
    case Integer.parse(id) do
      {int, ""} -> json_ok(conn, V2ProjectBoards.delete_response(int))
      _ -> json_error(conn, 400, "invalid board id")
    end
  end

  defp json_ok(conn, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> put_resp_header("x-request-id", "fake-board-v2")
    |> send_resp(conn.status || 200, Jason.encode!(body))
  end

  defp json_error(conn, status, message) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> put_resp_header("x-request-id", "fake-board-v2-error")
    |> send_resp(status, Jason.encode!(V2ProjectBoards.error_response(status, message)))
  end
end
