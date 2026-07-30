defmodule ExPipedrive.FakePersonV2ApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V2Persons

  def handle_list_persons_v2(conn, params) do
    case Map.get(params, "error") do
      "400" -> json_error(conn, 400, "bad request")
      "401" -> json_error(conn, 401, "unauthorized")
      "429" -> json_error(conn, 429, "rate limit exceeded")
      _ -> json_ok(conn, V2Persons.list_response(Map.get(params, "cursor")))
    end
  end

  def handle_get_person_v2(conn, %{"id" => "404"}) do
    json_error(conn, 404, "Person not found")
  end

  def handle_get_person_v2(conn, %{"id" => id}) do
    case Integer.parse(id) do
      {int, ""} -> json_ok(conn, V2Persons.get_response(int))
      _ -> json_error(conn, 400, "invalid person id")
    end
  end

  def handle_create_person_v2(%{body_params: body} = conn) do
    conn
    |> put_status(201)
    |> json_ok(V2Persons.create_response(body))
  end

  def handle_update_person_v2(%{body_params: body, params: %{"id" => id}} = conn) do
    {int, ""} = Integer.parse(id)
    json_ok(conn, V2Persons.update_response(int, body))
  end

  defp json_ok(conn, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> put_resp_header("x-request-id", "fake-person-v2")
    |> send_resp(conn.status || 200, Jason.encode!(body))
  end

  defp json_error(conn, status, message) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> put_resp_header("x-request-id", "fake-person-v2-error")
    |> send_resp(status, Jason.encode!(V2Persons.error_response(status, message)))
  end
end
