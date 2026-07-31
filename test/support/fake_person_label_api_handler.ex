defmodule ExPipedrive.FakePersonLabelApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V2PersonLabels

  def handle_get_person_label_field(conn, %{"field_code" => "label_ids"}) do
    json_ok(conn, V2PersonLabels.field_response())
  end

  def handle_add_person_label_options(%{body_params: %{"_json" => options}} = conn) do
    json_ok(conn, V2PersonLabels.add_options_response(options))
  end

  def handle_update_person_label_options(%{body_params: %{"_json" => options}} = conn) do
    json_ok(conn, V2PersonLabels.update_options_response(options))
  end

  def handle_delete_person_label_options(%{body_params: %{"_json" => options}} = conn) do
    json_ok(conn, V2PersonLabels.delete_options_response(options))
  end

  defp json_ok(conn, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(200, Jason.encode!(body))
  end
end
