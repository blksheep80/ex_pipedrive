defmodule ExPipedrive.FakeLeadFieldApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V1LeadFields

  def handle_list_lead_fields(conn, query_params) do
    start = Map.get(query_params, "start", "0")
    limit = Map.get(query_params, "limit", "500")

    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(200, Jason.encode!(V1LeadFields.list_response(start, limit)))
  end
end
