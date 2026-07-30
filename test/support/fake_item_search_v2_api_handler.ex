defmodule ExPipedrive.FakeItemSearchV2ApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V2ItemSearch

  def handle_item_search_v2(conn, params) do
    case Map.get(params, "term") do
      "__http_400__" ->
        json_error(conn, 400, "bad request")

      "__http_401__" ->
        json_error(conn, 401, "unauthorized")

      "__http_429__" ->
        json_error(conn, 429, "rate limit exceeded")

      term ->
        json_ok(conn, V2ItemSearch.search_response(term || "", params))
    end
  end

  defp json_ok(conn, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> put_resp_header("x-request-id", "fake-item-search-v2")
    |> send_resp(conn.status || 200, Jason.encode!(body))
  end

  defp json_error(conn, status, message) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> put_resp_header("x-request-id", "fake-item-search-v2-error")
    |> send_resp(status, Jason.encode!(V2ItemSearch.error_response(status, message)))
  end
end
