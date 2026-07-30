defmodule ExPipedrive.FakeDealApiHandler do
  @moduledoc false

  import Plug.Conn

  def handle_get_deal(conn, %{"id" => "1"}) do
    response_body = ~s"""
    {
      "success": true,
      "data": {
        "id": 1,
        "creator_user_id": {
          "id": 15783886,
          "name": "Tim Mecklem",
          "email": "tim+dev@launchscout.com",
          "has_pic": 0,
          "pic_hash": null,
          "active_flag": true,
          "value": 15783886
        },
        "user_id": {
          "id": 15783886,
          "name": "Tim Mecklem",
          "email": "tim+dev@launchscout.com",
          "has_pic": 0,
          "pic_hash": null,
          "active_flag": true,
          "value": 15783886
        },
        "person_id": {
          "active_flag": true,
          "name": "Tim Mecklem",
          "email": [
            {
              "value": "",
              "primary": true
            }
          ],
          "phone": [
            {
              "value": "",
              "primary": true
            }
          ],
          "owner_id": 15783886,
          "value": 1
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
        "person_hidden": false,
        "average_time_to_won": {
          "y": 0,
          "m": 0,
          "d": 0,
          "h": 0,
          "i": 0,
          "s": 0,
          "total_seconds": 0
        },
        "average_stage_progress": 0,
        "age": {
          "y": 0,
          "m": 0,
          "d": 0,
          "h": 11,
          "i": 21,
          "s": 21,
          "total_seconds": 40881
        },
        "stay_in_pipeline_stages": {
          "times_in_stages": {
            "1": 0,
            "2": 40881
          },
          "order_of_stages": [
            1,
            2
          ]
        },
        "last_activity": null,
        "next_activity": null
      },
      "additional_data": {
        "dropbox_email": "launchscout-sandbox+deal1@pipedrivemail.com"
      },
      "related_objects": {
        "user": {
          "15783886": {
            "id": 15783886,
            "name": "Tim Mecklem",
            "email": "tim+dev@launchscout.com",
            "has_pic": 0,
            "pic_hash": null,
            "active_flag": true
          }
        },
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
                "value": "",
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
        }
      }
    }
    """

    conn
    |> send_resp(200, response_body)
  end

  def handle_list_deals(conn, _opts) do
    response_body = ~s"""
      {
        "success": true,
        "data": [
          {
            "id": 1,
            "creator_user_id": {
              "id": 15783886,
              "name": "Tim Mecklem",
              "email": "tim+dev@launchscout.com",
              "has_pic": 0,
              "pic_hash": null,
              "active_flag": true,
              "value": 15783886
            },
            "user_id": {
              "id": 15783886,
              "name": "Tim Mecklem",
              "email": "tim+dev@launchscout.com",
              "has_pic": 0,
              "pic_hash": null,
              "active_flag": true,
              "value": 15783886
            },
            "person_id": {
              "active_flag": true,
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
              "owner_id": 15783886,
              "value": 1
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
            "stage_id": 2,
            "title": "Mecklem, LLC deal",
            "value": 30004,
            "currency": "USD",
            "add_time": "2022-07-09 15:16:27",
            "update_time": "2022-07-21 03:00:09",
            "stage_change_time": null,
            "active": true,
            "deleted": false,
            "status": "open",
            "probability": null,
            "next_activity_date": null,
            "next_activity_time": null,
            "next_activity_id": null,
            "last_activity_id": 2,
            "last_activity_date": "2030-10-01",
            "lost_reason": null,
            "visible_to": "3",
            "close_time": null,
            "pipeline_id": 1,
            "won_time": null,
            "first_won_time": "2022-07-21 02:44:22",
            "lost_time": null,
            "products_count": 0,
            "files_count": 0,
            "notes_count": 0,
            "followers_count": 1,
            "email_messages_count": 0,
            "activities_count": 2,
            "done_activities_count": 2,
            "undone_activities_count": 0,
            "participants_count": 1,
            "expected_close_date": "2022-07-21",
            "last_incoming_mail_time": null,
            "last_outgoing_mail_time": null,
            "label": null,
            "stage_order_nr": 1,
            "person_name": "Tim Mecklem",
            "org_name": "Mecklem, LLC",
            "next_activity_subject": null,
            "next_activity_type": null,
            "next_activity_duration": null,
            "next_activity_note": null,
            "formatted_value": "$30,004",
            "weighted_value": 30004,
            "formatted_weighted_value": "$30,004",
            "weighted_value_currency": "USD",
            "rotten_time": null,
            "owner_name": "Tim Mecklem",
            "cc_email": "launchscout-sandbox-tim+deal1@pipedrivemail.com",
            "org_hidden": false,
            "person_hidden": false
          }
          ],
        "additional_data": {
          "pagination": {
            "start": 0,
            "limit": 50,
            "more_items_in_collection": false
          }
        },
        "related_objects": {
          "user": {
            "15783886": {
              "id": 15783886,
              "name": "Tim Mecklem",
              "email": "tim+dev@launchscout.com",
              "has_pic": 0,
              "pic_hash": null,
              "active_flag": true
            },
            "11276935": {
              "id": 11276935,
              "name": "Chris Nelson",
              "email": "chris@launchscout.com",
              "has_pic": 1,
              "pic_hash": "2ebca6a9f230db83e7903787d753d78d",
              "active_flag": true
            }
          },
          "organization": {
            "1": {
              "id": 1,
              "name": "Mecklem, LLC",
              "people_count": 1,
              "owner_id": 15783886,
              "address": null,
              "active_flag": true,
              "cc_email": "launchscout-sandbox-tim@pipedrivemail.com",
              "owner_name": "Tim Mecklem"
            },
            "3": {
              "id": 3,
              "name": "Deal with It LLC",
              "people_count": 1,
              "owner_id": 11276935,
              "address": null,
              "active_flag": true,
              "cc_email": "launchscout-sandbox-tim@pipedrivemail.com",
              "owner_name": "Chris Nelson"
            }
          },
          "pipeline": {
            "1": {
              "id": 1,
              "name": "Pipeline",
              "url_title": "default",
              "order_nr": 1,
              "active": true,
              "deal_probability": false,
              "add_time": "2022-07-08 12:08:35",
              "update_time": null
            },
            "2": {
              "id": 2,
              "name": "Scott's Ultra Special Pipeline",
              "url_title": "Scotts-Ultra-Special-Pipeline",
              "order_nr": 2,
              "active": true,
              "deal_probability": true,
              "add_time": "2022-07-12 20:09:57",
              "update_time": "2022-07-12 20:09:57"
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
            "6": {
              "active_flag": true,
              "id": 6,
              "name": "Dealy McDealer",
              "email": [
                {
                  "value": "",
                  "primary": true
                }
              ],
              "phone": [
                {
                  "value": "",
                  "primary": true
                }
              ],
              "owner_id": 11276935
            }
          },
          "stage": {
            "2": {
              "id": 2,
              "company_id": 11796774,
              "order_nr": 1,
              "name": "Contact Made",
              "active_flag": true,
              "deal_probability": 100,
              "pipeline_id": 1,
              "rotten_flag": false,
              "rotten_days": null,
              "add_time": "2022-07-08 15:39:06",
              "update_time": null,
              "pipeline_name": "Pipeline",
              "pipeline_deal_probability": false
            },
            "7": {
              "id": 7,
              "company_id": 11796774,
              "order_nr": 1,
              "name": "Qualified",
              "active_flag": true,
              "deal_probability": 100,
              "pipeline_id": 2,
              "rotten_flag": false,
              "rotten_days": null,
              "add_time": "2022-07-12 20:09:57",
              "update_time": "2022-07-12 20:09:57",
              "pipeline_name": "Scott's Ultra Special Pipeline",
              "pipeline_deal_probability": true
            },
            "9": {
              "id": 9,
              "company_id": 11796774,
              "order_nr": 3,
              "name": "Demo Scheduled",
              "active_flag": true,
              "deal_probability": 100,
              "pipeline_id": 2,
              "rotten_flag": false,
              "rotten_days": null,
              "add_time": "2022-07-12 20:09:57",
              "update_time": "2022-07-12 20:09:57",
              "pipeline_name": "Scott's Ultra Special Pipeline",
              "pipeline_deal_probability": true
            },
            "1": {
              "id": 1,
              "company_id": 11796774,
              "order_nr": 0,
              "name": "Qualified",
              "active_flag": true,
              "deal_probability": 100,
              "pipeline_id": 1,
              "rotten_flag": false,
              "rotten_days": null,
              "add_time": "2022-07-08 15:39:06",
              "update_time": null,
              "pipeline_name": "Pipeline",
              "pipeline_deal_probability": false
            }
          }
        }
      }
    """

    conn
    |> send_resp(200, response_body)
  end

  def handle_search_deals(conn, %{"term" => _term}) do
    response_body = ~s"""
    {
      "success": true,
      "data": {
        "items": [
          {
            "result_score": 1.092828,
            "item": {
              "id": 2,
              "type": "deal",
              "title": "Great Amazing Deal",
              "value": 40000,
              "currency": "USD",
              "status": "open",
              "visible_to": 3,
              "owner": {
                "id": 15783886
              },
              "stage": {
                "id": 7,
                "name": "Qualified"
              },
              "person": {
                "id": 1,
                "name": "Tim Mecklem"
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
          "limit": 25,
          "more_items_in_collection": false
        }
      }
    }
    """

    conn
    |> send_resp(200, response_body)
  end
end
