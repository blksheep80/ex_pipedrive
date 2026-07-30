defmodule ExPipedrive.FakeStageV2ApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V2Stages

  def handle_list_stages_v2(conn, params) do
    case Map.get(params, "error") do
      "400" -> json_error(conn, 400, "bad request")
      "401" -> json_error(conn, 401, "unauthorized")
      "429" -> json_error(conn, 429, "rate limit exceeded")
      _ -> json_ok(conn, V2Stages.list_response(Map.get(params, "cursor")))
    end
  end

  def handle_get_stage_v2(conn, %{"id" => "404"}) do
    json_error(conn, 404, "Stage not found")
  end

  def handle_get_stage_v2(conn, %{"id" => id}) do
    case Integer.parse(id) do
      {int, ""} -> json_ok(conn, V2Stages.get_response(int))
      _ -> json_error(conn, 400, "invalid stage id")
    end
  end

  def handle_create_stage_v2(%{body_params: body} = conn) do
    json_ok(conn, V2Stages.create_response(body))
  end

  def handle_update_stage_v2(%{body_params: body, params: %{"id" => id}} = conn) do
    {int, ""} = Integer.parse(id)
    json_ok(conn, V2Stages.update_response(int, body))
  end

  def handle_delete_stage_v2(conn, %{"id" => "404"}) do
    json_error(conn, 404, "Stage not found")
  end

  def handle_delete_stage_v2(conn, %{"id" => id}) do
    case Integer.parse(id) do
      {int, ""} -> json_ok(conn, V2Stages.delete_response(int))
      _ -> json_error(conn, 400, "invalid stage id")
    end
  end

  defp json_ok(conn, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> put_resp_header("x-request-id", "fake-stage-v2")
    |> send_resp(conn.status || 200, Jason.encode!(body))
  end

  defp json_error(conn, status, message) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> put_resp_header("x-request-id", "fake-stage-v2-error")
    |> send_resp(status, Jason.encode!(V2Stages.error_response(status, message)))
  end
end
