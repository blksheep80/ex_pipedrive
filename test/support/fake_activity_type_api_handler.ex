defmodule ExPipedrive.FakeActivityTypeApiHandler do
  @moduledoc false

  import Plug.Conn

  def handle_list_activity_types(conn) do
    response_body = ~s"""
    {
      "success": true,
      "data": [
        {
          "id": 1,
          "order_nr": 1,
          "name": "Call",
          "key_string": "call",
          "icon_key": "call",
          "active_flag": true,
          "color": null,
          "is_custom_flag": false,
          "add_time": "2022-07-08 12:08:35",
          "update_time": null
        },
        {
          "id": 2,
          "order_nr": 2,
          "name": "Meeting",
          "key_string": "meeting",
          "icon_key": "meeting",
          "active_flag": true,
          "color": null,
          "is_custom_flag": false,
          "add_time": "2022-07-08 12:08:35",
          "update_time": null
        },
        {
          "id": 3,
          "order_nr": 3,
          "name": "Task",
          "key_string": "task",
          "icon_key": "task",
          "active_flag": true,
          "color": null,
          "is_custom_flag": false,
          "add_time": "2022-07-08 12:08:35",
          "update_time": null
        },
        {
          "id": 4,
          "order_nr": 4,
          "name": "Deadline",
          "key_string": "deadline",
          "icon_key": "deadline",
          "active_flag": true,
          "color": null,
          "is_custom_flag": false,
          "add_time": "2022-07-08 12:08:35",
          "update_time": null
        },
        {
          "id": 5,
          "order_nr": 5,
          "name": "Email",
          "key_string": "email",
          "icon_key": "email",
          "active_flag": true,
          "color": null,
          "is_custom_flag": false,
          "add_time": "2022-07-08 12:08:35",
          "update_time": null
        },
        {
          "id": 6,
          "order_nr": 6,
          "name": "Lunch",
          "key_string": "lunch",
          "icon_key": "lunch",
          "active_flag": true,
          "color": null,
          "is_custom_flag": false,
          "add_time": "2022-07-08 12:08:35",
          "update_time": null
        }
      ]
    }
    """

    conn
    |> send_resp(200, response_body)
  end
end
