defmodule ExPipedrive.FakeFieldV2ApiHandler do
  @moduledoc false

  import Plug.Conn

  def handle_list_fields_v2(conn, resource, _params) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(200, Jason.encode!(response(resource)))
  end

  defp response(resource) do
    %{
      "success" => true,
      "data" => [
        %{
          "field_code" => "id",
          "field_name" => "ID",
          "field_type" => "int",
          "is_custom_field" => false,
          "options" => nil
        },
        %{
          "field_code" => "#{resource}_custom_hash",
          "field_name" => "#{resource |> String.capitalize()} tier",
          "field_type" => "enum",
          "is_custom_field" => true,
          "options" => [
            %{"id" => 21, "label" => "Gold"},
            %{"id" => 22, "label" => "Silver"}
          ]
        }
      ],
      "additional_data" => %{"next_cursor" => nil}
    }
  end
end
