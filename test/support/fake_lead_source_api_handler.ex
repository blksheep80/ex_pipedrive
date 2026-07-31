defmodule ExPipedrive.FakeLeadSourceApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V1LeadSources

  def handle_list_lead_sources(conn) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(200, Jason.encode!(V1LeadSources.list_response()))
  end
end
