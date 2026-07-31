defmodule ExPipedrive.FakeLeadLabelApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V1LeadLabels

  def handle_list_lead_labels(conn) do
    json_ok(conn, V1LeadLabels.list_response())
  end

  def handle_create_lead_label(%{body_params: attrs} = conn) do
    conn
    |> put_status(201)
    |> json_ok(V1LeadLabels.create_response(attrs))
  end

  def handle_update_lead_label(%{body_params: attrs, params: %{"id" => id}} = conn) do
    json_ok(conn, V1LeadLabels.update_response(id, attrs))
  end

  def handle_delete_lead_label(conn, %{"id" => id}) do
    json_ok(conn, V1LeadLabels.delete_response(id))
  end

  defp json_ok(conn, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(conn.status || 200, Jason.encode!(body))
  end
end
