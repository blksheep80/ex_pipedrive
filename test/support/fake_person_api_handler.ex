defmodule ExPipedrive.FakePersonApiHandler do
  @moduledoc false

  import Plug.Conn

  def handle_list_persons(conn) do
    response_body = ~s"""
    {
      "success": true,
      "data": [
        {
          "id": 1,
          "company_id": 11796774,
          "owner_id": {
            "id": 15783886,
            "name": "Tim Mecklem",
            "email": "tim+dev@launchscout.com",
            "has_pic": 0,
            "pic_hash": null,
            "active_flag": true,
            "value": 15783886
          },
          "org_id": {
            "name": "Mecklem, LLC",
            "people_count": 1,
            "owner_id": 15783886,
            "address": null,
            "active_flag": true,
            "cc_email": "launchscout-sandbox-tim@pipedrivemail.com",
            "owner_name": "Tim Mecklem",
            "value": 1
          },
          "name": "Tim Mecklem",
          "first_name": "Tim",
          "last_name": "Mecklem",
          "open_deals_count": 3,
          "related_open_deals_count": 0,
          "closed_deals_count": 5,
          "related_closed_deals_count": 2,
          "participant_open_deals_count": 0,
          "participant_closed_deals_count": 0,
          "email_messages_count": 0,
          "activities_count": 19,
          "done_activities_count": 14,
          "undone_activities_count": 5,
          "files_count": 0,
          "notes_count": 0,
          "followers_count": 1,
          "won_deals_count": 0,
          "related_won_deals_count": 0,
          "lost_deals_count": 0,
          "related_lost_deals_count": 0,
          "active_flag": true,
          "phone": [
            {
              "value": "",
              "primary": true
            }
          ],
          "email": [
            {
              "label": "work",
              "value": "tim@launchscout.com",
              "primary": true
            }
          ],
          "first_char": "t",
          "update_time": "2023-02-22 22:05:25",
          "delete_time": null,
          "add_time": "2022-07-09 15:16:26",
          "visible_to": "3",
          "picture_id": {
            "item_type": "person",
            "item_id": 1,
            "active_flag": true,
            "add_time": "2023-02-14 15:10:42",
            "update_time": "0000-00-00 00:00:00",
            "added_by_user_id": 17120881,
            "pictures": {
              "128": "https://www.gravatar.com/avatar/a623a27501314ebcb1ca52e49d9e3122?s=128&d=404&r=g",
              "512": "https://www.gravatar.com/avatar/a623a27501314ebcb1ca52e49d9e3122?s=512&d=404&r=g"
            },
            "value": 1
          },
          "next_activity_date": "2022-07-20",
          "next_activity_time": null,
          "next_activity_id": 5,
          "last_activity_id": 2,
          "last_activity_date": "2030-10-01",
          "last_incoming_mail_time": null,
          "last_outgoing_mail_time": "2022-08-19 19:13:53",
          "label": null,
          "org_name": "Mecklem, LLC",
          "owner_name": "Tim Mecklem",
          "primary_email": "tim@launchscout.com",
          "8a9fba4ea88bbe2bde6a32efa89960fbdb4f8c71": null,
          "cc_email": "launchscout-sandbox-tim@pipedrivemail.com"
        }
      ],
      "additional_data": {
        "pagination": {
          "start": 0,
          "limit": 2,
          "more_items_in_collection": true
        }
      },
      "related_objects": {
      }
    }
    """

    conn
    |> send_resp(200, response_body)
  end

  def handle_search_persons(conn, %{"term" => "tim"}) do
    response_body = ~s"""
    {
      "success": true,
      "data": {
        "items": [
          {
            "result_score": 0.09985,
            "item": {
              "id": 1,
              "type": "person",
              "name": "Tim Mecklem",
              "phones": [],
              "emails": [],
              "primary_email": null,
              "visible_to": 3,
              "owner": {
                "id": 15783886
              },
              "organization": {
                "id": 1,
                "name": "Mecklem, LLC",
                "address": null
              },
              "custom_fields": [],
              "notes": []
            }
          }
        ]
      },
      "additional_data": {
        "pagination": {
          "start": 0,
          "limit": 50,
          "more_items_in_collection": false
        }
      }
    }
    """

    conn
    |> send_resp(200, response_body)
  end

  def handle_get_person(conn, %{"id" => "1"}) do
    response_body = ~s"""
      {
        "success": true,
        "data": {
          "id": 1,
          "company_id": 11796774,
          "owner_id": {
            "id": 15783886,
            "name": "Tim Mecklem",
            "email": "tim+dev@launchscout.com",
            "has_pic": 0,
            "pic_hash": null,
            "active_flag": true,
            "value": 15783886
          },
          "org_id": {
            "name": "Mecklem, LLC",
            "people_count": 1,
            "owner_id": 15783886,
            "address": null,
            "active_flag": true,
            "cc_email": "launchscout-sandbox@pipedrivemail.com",
            "value": 1
          },
          "name": "Tim Mecklem",
          "first_name": "Tim",
          "last_name": "Mecklem",
          "open_deals_count": 1,
          "related_open_deals_count": 0,
          "closed_deals_count": 0,
          "related_closed_deals_count": 0,
          "participant_open_deals_count": 0,
          "participant_closed_deals_count": 0,
          "email_messages_count": 0,
          "activities_count": 0,
          "done_activities_count": 0,
          "undone_activities_count": 0,
          "files_count": 0,
          "notes_count": 0,
          "followers_count": 1,
          "won_deals_count": 0,
          "related_won_deals_count": 0,
          "lost_deals_count": 0,
          "related_lost_deals_count": 0,
          "active_flag": true,
          "phone": [
            {
              "value": "",
              "primary": true
            }
          ],
          "email": [
            {
              "value": "",
              "primary": true
            }
          ],
          "first_char": "t",
          "update_time": "2022-07-09 15:16:27",
          "add_time": "2022-07-09 15:16:26",
          "visible_to": "3",
          "picture_id": null,
          "next_activity_date": null,
          "next_activity_time": null,
          "next_activity_id": null,
          "last_activity_id": null,
          "last_activity_date": null,
          "last_incoming_mail_time": null,
          "last_outgoing_mail_time": null,
          "label": null,
          "org_name": "Mecklem, LLC",
          "cc_email": "launchscout-sandbox@pipedrivemail.com",
          "primary_email": null,
          "owner_name": "Tim Mecklem"
        },
        "additional_data": {
          "dropbox_email": "launchscout-sandbox@pipedrivemail.com"
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
    |> send_resp(200, response_body)
  end

  def handle_create_person(%{body_params: %{"name" => name}} = conn) do
    response_body = ~s"""
      {
        "success": true,
        "data": {
          "id": 1,
          "company_id": 11796774,
          "owner_id": {
            "id": 15783886,
            "name": "Tim Mecklem",
            "email": "tim+dev@launchscout.com",
            "has_pic": 0,
            "pic_hash": null,
            "active_flag": true,
            "value": 15783886
          },
          "org_id": {
            "name": "Mecklem, LLC",
            "people_count": 1,
            "owner_id": 15783886,
            "address": null,
            "active_flag": true,
            "cc_email": "launchscout-sandbox@pipedrivemail.com",
            "value": 1
          },
          "name": "#{name}",
          "first_name": "Tim",
          "last_name": "Mecklem",
          "open_deals_count": 1,
          "related_open_deals_count": 0,
          "closed_deals_count": 0,
          "related_closed_deals_count": 0,
          "participant_open_deals_count": 0,
          "participant_closed_deals_count": 0,
          "email_messages_count": 0,
          "activities_count": 0,
          "done_activities_count": 0,
          "undone_activities_count": 0,
          "files_count": 0,
          "notes_count": 0,
          "followers_count": 1,
          "won_deals_count": 0,
          "related_won_deals_count": 0,
          "lost_deals_count": 0,
          "related_lost_deals_count": 0,
          "active_flag": true,
          "phone": [
            {
              "value": "",
              "primary": true
            }
          ],
          "email": [
            {
              "value": "",
              "primary": true
            }
          ],
          "first_char": "t",
          "update_time": "2022-07-09 15:16:27",
          "add_time": "2022-07-09 15:16:26",
          "visible_to": "3",
          "picture_id": null,
          "next_activity_date": null,
          "next_activity_time": null,
          "next_activity_id": null,
          "last_activity_id": null,
          "last_activity_date": null,
          "last_incoming_mail_time": null,
          "last_outgoing_mail_time": null,
          "label": null,
          "org_name": "Mecklem, LLC",
          "cc_email": "launchscout-sandbox@pipedrivemail.com",
          "primary_email": null,
          "owner_name": "Tim Mecklem"
        },
        "additional_data": {
          "dropbox_email": "launchscout-sandbox@pipedrivemail.com"
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
end
