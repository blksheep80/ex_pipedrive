defmodule ExPipedrive.FakePipelineApiHandler do
  @moduledoc false

  import Plug.Conn

  def handle_list_pipelines(conn) do
    response_body = ~s"""
    {
      "success": true,
      "data": [
        {
          "id": 1,
          "name": "Pipeline",
          "url_title": "default",
          "order_nr": 1,
          "active": true,
          "deal_probability": false,
          "add_time": "2022-07-08 12:08:35",
          "update_time": null,
          "selected": true
        }
      ],
      "additional_data": {
        "pagination": {
          "start": 0,
          "limit": 100,
          "more_items_in_collection": false
        }
      }
    }
    """

    conn
    |> send_resp(200, response_body)
  end

  def handle_list_pipeline_deals(conn, _) do
    response_body = ~s"""
    {
      "success": true,
      "data": [
        {
          "id": 1,
          "creator_user_id": 15783886,
          "user_id": 15783886,
          "person_id": 1,
          "org_id": 1,
          "stage_id": 2,
          "title": "Mecklem, LLC deal",
          "value": 30000,
          "currency": "USD",
          "add_time": "2022-07-09 15:16:27",
          "update_time": "2022-07-09 15:16:27",
          "stage_change_time": null,
          "active": true,
          "deleted": false,
          "status": "open",
          "probability": null,
          "next_activity_date": null,
          "next_activity_time": null,
          "next_activity_id": null,
          "last_activity_id": null,
          "last_activity_date": null,
          "lost_reason": null,
          "visible_to": "3",
          "close_time": null,
          "pipeline_id": 1,
          "won_time": null,
          "first_won_time": null,
          "lost_time": null,
          "products_count": 0,
          "files_count": 0,
          "notes_count": 0,
          "followers_count": 1,
          "email_messages_count": 0,
          "activities_count": 0,
          "done_activities_count": 0,
          "undone_activities_count": 0,
          "participants_count": 1,
          "expected_close_date": "2022-07-21",
          "last_incoming_mail_time": null,
          "last_outgoing_mail_time": null,
          "label": null,
          "renewal_type": "one_time",
          "stage_order_nr": 1,
          "person_name": "Tim Mecklem",
          "org_name": "Mecklem, LLC",
          "next_activity_subject": null,
          "next_activity_type": null,
          "next_activity_duration": null,
          "next_activity_note": null,
          "group_id": null,
          "group_name": null,
          "formatted_value": "$30,000",
          "weighted_value": 30000,
          "formatted_weighted_value": "$30,000",
          "weighted_value_currency": "USD",
          "rotten_time": null,
          "owner_name": "Tim Mecklem",
          "cc_email": "launchscout-sandbox+deal1@pipedrivemail.com",
          "org_hidden": false,
          "person_hidden": false
        }
      ],
      "additional_data": {
        "pagination": {
          "start": 0,
          "limit": 100,
          "more_items_in_collection": false
        }
      }
    }
    """

    conn
    |> send_resp(200, response_body)
  end
end
