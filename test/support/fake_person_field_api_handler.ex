defmodule ExPipedrive.FakePersonFieldApiHandler do
  @moduledoc false

  import Plug.Conn

  def handle_list_person_fields(conn) do
    response_body = ~s"""
    {
      "success": true,
      "data": [
          {
          "id": 9051,
          "key": "id",
          "name": "ID",
          "group_id": null,
          "order_nr": 0,
          "field_type": "int",
          "json_column_flag": false,
          "add_time": "2022-07-08 12:08:35",
          "update_time": "2022-07-08 12:08:35",
          "last_updated_by_user_id": null,
          "edit_flag": false,
          "details_visible_flag": false,
          "add_visible_flag": false,
          "important_flag": false,
          "bulk_edit_allowed": false,
          "filtering_allowed": true,
          "sortable_flag": true,
          "searchable_flag": false,
          "active_flag": true,
          "mandatory_flag": true
          },
          {
            "id": 9064,
            "key": "8a9fba4ea88bbe2bde6a32efa89960fbdb4f8c71",
            "name": "Things",
            "group_id": null,
            "order_nr": 1,
            "field_type": "set",
            "json_column_flag": true,
            "add_time": "2023-03-20 20:00:12",
            "update_time": "2023-03-20 20:00:11",
            "last_updated_by_user_id": 11276935,
            "edit_flag": true,
            "details_visible_flag": true,
            "add_visible_flag": false,
            "important_flag": true,
            "bulk_edit_allowed": true,
            "filtering_allowed": true,
            "sortable_flag": true,
            "searchable_flag": true,
            "active_flag": true,
            "options": [
              {
                "id": 21,
                "label": "good"
              },
              {
                "id": 22,
                "label": "bad"
              },
              {
                "id": 23,
                "label": "indifferent"
              }
            ],
            "mandatory_flag": false
          }
        ],
        "additional_data": {
          "pagination": {
            "start": 0,
            "limit": 2,
            "more_items_in_collection": false
          }
        }
      }
    """

    conn
    |> send_resp(200, response_body)
  end
end
