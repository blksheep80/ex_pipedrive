defmodule ExPipedrive.FakeActivityTypeApiHandler do
  @moduledoc false

  import Plug.Conn

  @types [
    %{
      "id" => 1,
      "order_nr" => 1,
      "name" => "Call",
      "key_string" => "call",
      "icon_key" => "call",
      "active_flag" => true,
      "color" => nil,
      "is_custom_flag" => false,
      "add_time" => "2022-07-08 12:08:35",
      "update_time" => nil
    },
    %{
      "id" => 2,
      "order_nr" => 2,
      "name" => "Meeting",
      "key_string" => "meeting",
      "icon_key" => "meeting",
      "active_flag" => true,
      "color" => nil,
      "is_custom_flag" => false,
      "add_time" => "2022-07-08 12:08:35",
      "update_time" => nil
    },
    %{
      "id" => 3,
      "order_nr" => 3,
      "name" => "Task",
      "key_string" => "task",
      "icon_key" => "task",
      "active_flag" => true,
      "color" => nil,
      "is_custom_flag" => false,
      "add_time" => "2022-07-08 12:08:35",
      "update_time" => nil
    },
    %{
      "id" => 4,
      "order_nr" => 4,
      "name" => "Deadline",
      "key_string" => "deadline",
      "icon_key" => "deadline",
      "active_flag" => true,
      "color" => nil,
      "is_custom_flag" => false,
      "add_time" => "2022-07-08 12:08:35",
      "update_time" => nil
    },
    %{
      "id" => 5,
      "order_nr" => 5,
      "name" => "Email",
      "key_string" => "email",
      "icon_key" => "email",
      "active_flag" => true,
      "color" => nil,
      "is_custom_flag" => false,
      "add_time" => "2022-07-08 12:08:35",
      "update_time" => nil
    },
    %{
      "id" => 6,
      "order_nr" => 6,
      "name" => "Lunch",
      "key_string" => "lunch",
      "icon_key" => "lunch",
      "active_flag" => true,
      "color" => nil,
      "is_custom_flag" => false,
      "add_time" => "2022-07-08 12:08:35",
      "update_time" => nil
    }
  ]

  @custom %{
    "id" => 12,
    "order_nr" => 1,
    "name" => "Video call",
    "key_string" => "video_call",
    "icon_key" => "camera",
    "active_flag" => true,
    "color" => "aeb31b",
    "is_custom_flag" => true,
    "add_time" => "2020-09-01 10:16:23",
    "update_time" => "2020-09-01 10:16:23"
  }

  def handle_list_activity_types(conn) do
    json(conn, 200, %{"success" => true, "data" => @types})
  end

  def handle_create_activity_type(%{body_params: body} = conn) do
    type =
      @custom
      |> Map.merge(Map.take(body, ["name", "icon_key", "color", "order_nr"]))
      |> Map.put("key_string", body |> Map.get("name", "video_call") |> to_key_string())
      |> Map.put("is_custom_flag", true)

    json(conn, 200, %{"success" => true, "data" => type})
  end

  def handle_update_activity_type(%{body_params: body, params: %{"id" => "12"}} = conn) do
    type = Map.merge(@custom, Map.take(body, ["name", "icon_key", "color", "order_nr"]))
    json(conn, 200, %{"success" => true, "data" => type})
  end

  def handle_update_activity_type(%{params: %{"id" => "404"}} = conn) do
    json(conn, 404, %{"success" => false, "error" => "Activity type not found"})
  end

  def handle_delete_activity_type(conn, %{"id" => "12"}) do
    json(conn, 200, %{"success" => true, "data" => Map.put(@custom, "active_flag", false)})
  end

  def handle_delete_activity_type(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Activity type not found"})
  end

  defp to_key_string(name) when is_binary(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "_")
    |> String.trim("_")
  end

  defp to_key_string(_), do: "custom"

  defp json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(status, Jason.encode!(body))
  end
end
