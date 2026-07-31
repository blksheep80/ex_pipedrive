defmodule ExPipedrive.FakeDealLabelApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V2DealLabels

  def handle_get_deal_label_field(conn, %{"field_code" => "error-400"}) do
    json_error(conn, 400, "bad request")
  end

  def handle_get_deal_label_field(conn, %{"field_code" => "label_ids"}) do
    json_ok(conn, V2DealLabels.field_response())
  end

  def handle_add_deal_label_options(%{body_params: %{"_json" => options}} = conn) do
    json_ok(conn, V2DealLabels.add_options_response(options))
  end

  def handle_update_deal_label_options(%{body_params: %{"_json" => options}} = conn) do
    json_ok(conn, V2DealLabels.update_options_response(options))
  end

  def handle_delete_deal_label_options(%{body_params: %{"_json" => options}} = conn) do
    json_ok(conn, V2DealLabels.delete_options_response(options))
  end

  defp json_ok(conn, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(200, Jason.encode!(body))
  end

  defp json_error(conn, status, message) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(status, Jason.encode!(V2DealLabels.error_response(status, message)))
  end
end
