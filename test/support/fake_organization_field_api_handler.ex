defmodule ExPipedrive.FakeOrganizationFieldApiHandler do
  @moduledoc false

  import Plug.Conn

  def handle_get_org_field_keys_and_names(conn, _opts) do
    response_body = ~s"""
    {
      "success": true,
      "data": [
        {
          "id": 4002,
          "key": "name",
          "name": "Name",
          "order_nr": 1,
          "field_type": "varchar",
          "json_column_flag": false,
          "add_time": "2022-08-22 21:35:48",
          "update_time": "2022-08-22 21:35:48",
          "last_updated_by_user_id": null,
          "edit_flag": false,
          "details_visible_flag": false,
          "add_visible_flag": true,
          "important_flag": false,
          "bulk_edit_allowed": true,
          "filtering_allowed": true,
          "sortable_flag": true,
          "mandatory_flag": true,
          "link": "/organization/",
          "use_field": "id",
          "active_flag": true,
          "index_visible_flag": true,
          "searchable_flag": false
        },
        {
          "id": 4024,
          "key": "93fc28f7d5aee87fc6484441cab648760a6c0d2d",
          "name": "Tech Stack",
          "order_nr": 23,
          "field_type": "varchar",
          "json_column_flag": true,
          "add_time": "2023-02-15 16:36:27",
          "update_time": "2023-02-15 16:36:26",
          "last_updated_by_user_id": 1,
          "edit_flag": true,
          "details_visible_flag": true,
          "add_visible_flag": true,
          "important_flag": true,
          "bulk_edit_allowed": true,
          "filtering_allowed": true,
          "sortable_flag": true,
          "mandatory_flag": false,
          "active_flag": true,
          "index_visible_flag": true,
          "searchable_flag": true
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
