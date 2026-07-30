defmodule ExPipedrive.FakeActivityApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Activity

  def handle_add_activity(%{body_params: activity_map} = conn) do
    activity = Activity.new(activity_map |> Map.new(fn {k, v} -> {String.to_atom(k), v} end))

    response_body = ~s"""
    {
      "success": true,
      "data": {
        "id": 2,
        "company_id": 11796774,
        "user_id": 15783886,
        "done": #{activity.done || 0},
        "type": "#{activity.type || "Call"}",
        "reference_type": null,
        "reference_id": null,
        "conference_meeting_client": null,
        "conference_meeting_url": null,
        "due_date": "#{Date.to_iso8601(activity.due_date)}",
        "due_time": "#{activity.due_time}",
        "busy_flag": #{activity.busy_flag},
        "add_time": "2022-07-15 21:14:14",
        "marked_as_done_time": "2022-07-15 21:14:14",
        "last_notification_time": null,
        "last_notification_user_id": null,
        "notification_language_id": null,
        "subject": "#{activity.subject}",
        "public_description": "#{activity.public_description}",
        "calendar_sync_include_context": null,
        "location": "location",
        "org_id": 1,
        "person_id": 1,
        "deal_id": #{activity.deal_id},
        "active_flag": true,
        "update_time": "2022-07-15 21:14:14",
        "update_user_id": null,
        "source_timezone": null,
        "rec_rule": null,
        "rec_rule_extension": null,
        "rec_master_activity_id": null,
        "conference_meeting_id": null,
        "note": "#{activity.note}",
        "created_by_user_id": 15783886,
        "location_subpremise": null,
        "location_street_number": null,
        "location_route": null,
        "location_sublocality": null,
        "location_locality": null,
        "location_admin_area_level_1": null,
        "location_admin_area_level_2": null,
        "location_country": null,
        "location_postal_code": null,
        "location_formatted_address": null,
        "attendees": null,
        "series": null,
        "is_recurring": null,
        "org_name": "Mecklem, LLC",
        "person_name": "Tim Mecklem",
        "deal_title": "Mecklem, LLC deal",
        "lead_title": null,
        "owner_name": "Tim Mecklem",
        "person_dropbox_bcc": "launchscout-sandbox@pipedrivemail.com",
        "deal_dropbox_bcc": "launchscout-sandbox+deal1@pipedrivemail.com",
        "assigned_to_user_id": 15783886,
        "type_name": "Call",
        "lead": null
      },
      "additional_data": {
        "more_activities_scheduled_in_context": false,
        "updates_story_id": 10
      },
      "related_objects": {
        "organization": {
          "1": {
            "id": 1,
            "name": "Mecklem, LLC",
            "people_count": 1,
            "owner_id": 15783886,
            "address": null,
            "active_flag": true,
            "cc_email": "launchscout-sandbox@pipedrivemail.com"
          }
        },
        "person": {
          "1": {
            "active_flag": true,
            "id": 1,
            "name": "Tim Mecklem",
            "email": [
              {
                "label": "work",
                "value": "tim@launchscout.com",
                "primary": true
              }
            ],
            "phone": [
              {
                "value": "",
                "primary": true
              }
            ],
            "owner_id": 15783886
          },
          "2": {
            "active_flag": true,
            "id": 2,
            "name": "Tina Marcklem",
            "email": [
              {
                "label": "work",
                "value": "tina.marklem@test.example",
                "primary": true
              }
            ],
            "phone": [
              {
                "value": "",
                "primary": true
              }
            ],
            "owner_id": 15783886
          }
        },
        "deal": {
          "1": {
            "id": 1,
            "title": "Mecklem, LLC deal",
            "status": "open",
            "value": 30000,
            "currency": "USD",
            "stage_id": 2,
            "pipeline_id": 1
          }
        },
        "user": {
          "15783886": {
            "id": 15783886,
            "name": "Tim Mecklem",
            "email": "tim+dev@launchscout.com",
            "has_pic": 0,
            "pic_hash": null,
            "active_flag": true
          }
        }
      }
    }
    """

    conn
    |> send_resp(201, response_body)
  end

  def handle_list_activities(conn) do
    response_body = ~s"""
    {
      "success": true,
      "data": [
        {
          "id": 1,
          "company_id": 11796774,
          "user_id": 15783886,
          "done": false,
          "type": "call",
          "due_date": "2024-03-20",
          "due_time": "10:00",
          "duration": "01:00",
          "busy_flag": true,
          "add_time": "2024-03-20 09:00:00",
          "subject": "Test Activity",
          "deal_id": 50,
          "person_id": 1,
          "org_id": 1,
          "location": "Office",
          "public_description": "Public description"
        }
      ],
      "additional_data": {
        "next_cursor": "MTIzNDU2Nzg5MA==",
        "limit": 100
      }
    }
    """

    conn
    |> send_resp(200, response_body)
  end

  def handle_list_own_activities(%{query_params: params} = conn) do
    limit = String.to_integer(params["limit"] || "100")
    start = String.to_integer(params["start"] || "0")
    start_date = params["start_date"]
    end_date = params["end_date"]

    # Simulate date filtering in the response
    activities =
      if start_date || end_date do
        [
          %{
            "id" => 3,
            "company_id" => 11_796_774,
            "user_id" => 15_783_886,
            "done" => false,
            "type" => "call",
            "due_date" => start_date || "2024-03-20",
            "due_time" => "10:00",
            "duration" => "01:00",
            "busy_flag" => true,
            "add_time" => "2024-03-20 09:00:00",
            "subject" => "Own Activity",
            "deal_id" => 50,
            "person_id" => 1,
            "org_id" => 1,
            "location" => "Office",
            "public_description" => "Own activity description"
          }
        ]
      else
        [
          %{
            "id" => 3,
            "company_id" => 11_796_774,
            "user_id" => 15_783_886,
            "done" => false,
            "type" => "call",
            "due_date" => "2024-03-20",
            "due_time" => "10:00",
            "duration" => "01:00",
            "busy_flag" => true,
            "add_time" => "2024-03-20 09:00:00",
            "subject" => "Own Activity",
            "deal_id" => 50,
            "person_id" => 1,
            "org_id" => 1,
            "location" => "Office",
            "public_description" => "Own activity description"
          }
        ]
      end

    response_body = %{
      "success" => true,
      "data" => activities,
      "additional_data" => %{
        "pagination" => %{
          "start" => start,
          "limit" => limit,
          "more_items_in_collection" => false
        }
      }
    }

    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(200, Jason.encode!(response_body))
  end
end
