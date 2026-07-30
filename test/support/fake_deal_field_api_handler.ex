defmodule ExPipedrive.FakeDealFieldApiHandler do
  @moduledoc false

  import Plug.Conn

  def handle_list_deal_fields(conn) do
    response_body = ~s"""
    {
      "success": true,
      "data": [
        {
          "id": 12477,
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
          "restriction_settings": [],
          "user_restrictions": null,
          "active_flag": true,
          "projects_detail_visible_flag": false,
          "show_in_pipelines": {
            "show_in_all": true,
            "pipeline_ids": []
          },
          "mandatory_flag": true
        },
        {
          "id": 12488,
          "key": "a31aaf5e2c4843027e1e183d7001686afb9781d0",
          "name": "swat",
          "group_id": null,
          "order_nr": 1,
          "field_type": "set",
          "json_column_flag": true,
          "add_time": "2023-08-24 15:37:24",
          "update_time": "2023-08-24 15:37:24",
          "last_updated_by_user_id": 15783886,
          "edit_flag": true,
          "details_visible_flag": true,
          "add_visible_flag": true,
          "important_flag": false,
          "bulk_edit_allowed": true,
          "filtering_allowed": true,
          "sortable_flag": true,
          "searchable_flag": true,
          "restriction_settings": [],
          "user_restrictions": null,
          "active_flag": true,
          "projects_detail_visible_flag": false,
          "show_in_pipelines": {
            "show_in_all": true,
            "pipeline_ids": []
          },
          "options": [
            {
              "id": 25,
              "label": "or not"
            },
            {
              "id": 26,
              "label": ", akond of"
            }
          ],
          "mandatory_flag": false
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
