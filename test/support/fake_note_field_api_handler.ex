defmodule ExPipedrive.FakeNoteFieldApiHandler do
  @moduledoc false

  import Plug.Conn

  def handle_list_note_fields(conn) do
    response_body = ~s"""
    {
      "success": true,
      "data": [
        {
          "id": 3901,
          "key": "id",
          "name": "ID",
          "order_nr": 0,
          "field_type": "int",
          "active_flag": true,
          "edit_flag": false,
          "bulk_edit_allowed": false,
          "mandatory_flag": true
        },
        {
          "id": 3912,
          "key": "b7c4e2a1f9038d5e6a2b1c0d9e8f7a6b5c4d3e2",
          "name": "Note category",
          "order_nr": 1,
          "field_type": "enum",
          "active_flag": true,
          "edit_flag": true,
          "bulk_edit_allowed": true,
          "mandatory_flag": false,
          "options": [
            {
              "id": 31,
              "label": "Follow-up"
            },
            {
              "id": 32,
              "label": "Internal"
            }
          ]
        }
      ],
      "additional_data": {
        "pagination": {
          "start": 0,
          "limit": 500,
          "more_items_in_collection": false
        }
      }
    }
    """

    conn
    |> send_resp(200, response_body)
  end
end
