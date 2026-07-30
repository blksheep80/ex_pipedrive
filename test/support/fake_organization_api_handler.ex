defmodule ExPipedrive.FakeOrganizationApiHandler do
  @moduledoc false

  import Plug.Conn

  def handle_get_organization(conn, %{"id" => "1"}) do
    response_body = ~s"""
    {
      "success": true,
      "data": {
          "id": 1,
          "company_id": 12656204,
          "owner_id": {
              "id": 17269766,
              "name": "Al",
              "email": "al+pipedrive@launchscout.com",
              "has_pic": 0,
              "pic_hash": null,
              "active_flag": true,
              "value": 17269766
          },
          "name": "An Org",
          "open_deals_count": 1,
          "related_open_deals_count": 0,
          "closed_deals_count": 0,
          "related_closed_deals_count": 0,
          "email_messages_count": 0,
          "people_count": 0,
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
          "category_id": null,
          "picture_id": null,
          "country_code": null,
          "first_char": "a",
          "update_time": "2023-01-18 21:35:54",
          "delete_time": null,
          "add_time": "2023-01-18 21:35:54",
          "visible_to": "3",
          "next_activity_date": null,
          "next_activity_time": null,
          "next_activity_id": null,
          "last_activity_id": null,
          "last_activity_date": null,
          "label": null,
          "address": null,
          "address_subpremise": null,
          "address_street_number": null,
          "address_route": null,
          "address_sublocality": null,
          "address_locality": null,
          "address_admin_area_level_1": null,
          "address_admin_area_level_2": null,
          "address_country": null,
          "address_postal_code": null,
          "address_formatted_address": null,
          "cc_email": "launchscout-sandbox+deal1@pipedrivemail.com",
          "owner_name": "Al",
          "edit_name": true,
          "last_activity": null,
          "next_activity": null
      },
      "additional_data": {
          "followers": {
              "17269766": {
                  "name": "Al",
                  "email": "launchscout-sandbox+deal1@pipedrivemail.com",
                  "user_id": 17269766,
                  "pic_hash": null,
                  "id": 1
              }
          },
          "dropbox_email": "launchscout-sandbox+deal1@pipedrivemail.com"
      },
      "related_objects": {
          "user": {
              "17269766": {
                  "id": 17269766,
                  "name": "Al",
                  "email": "al+pipedrive@launchscout.com",
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

  def handle_create_organization(%{body_params: %{"name" => _name}} = conn) do
    response_body = ~s"""
    {
      "success": true,
      "data": {
          "id": 1,
          "company_id": 12656204,
          "owner_id": {
              "id": 17269766,
              "name": "Al",
              "email": "al+pipedrive@launchscout.com",
              "has_pic": 0,
              "pic_hash": null,
              "active_flag": true,
              "value": 17269766
          },
          "name": "New Org",
          "open_deals_count": 0,
          "related_open_deals_count": 0,
          "closed_deals_count": 0,
          "related_closed_deals_count": 0,
          "email_messages_count": 0,
          "people_count": 0,
          "activities_count": 0,
          "done_activities_count": 0,
          "undone_activities_count": 0,
          "files_count": 0,
          "notes_count": 0,
          "followers_count": 0,
          "won_deals_count": 0,
          "related_won_deals_count": 0,
          "lost_deals_count": 0,
          "related_lost_deals_count": 0,
          "active_flag": true,
          "category_id": null,
          "picture_id": null,
          "country_code": null,
          "first_char": "n",
          "update_time": "2023-01-30 15:56:17",
          "delete_time": null,
          "add_time": "2023-01-30 15:56:16",
          "visible_to": "3",
          "next_activity_date": null,
          "next_activity_time": null,
          "next_activity_id": null,
          "last_activity_id": null,
          "last_activity_date": null,
          "label": null,
          "address": null,
          "address_subpremise": null,
          "address_street_number": null,
          "address_route": null,
          "address_sublocality": null,
          "address_locality": null,
          "address_admin_area_level_1": null,
          "address_admin_area_level_2": null,
          "address_country": null,
          "address_postal_code": null,
          "address_formatted_address": null,
          "cc_email": "al-sandbox@pipedrivemail.com",
          "owner_name": "Al",
          "edit_name": true
      },
      "related_objects": {
          "user": {
              "17269766": {
                  "id": 17269766,
                  "name": "Al",
                  "email": "al+pipedrive@launchscout.com",
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

  def handle_update_organization(
        %{body_params: %{"93fc28f7d5aee87fc6484441cab648760a6c0d2d" => _value}} = conn
      ) do
    response_body = ~s"""
    {
        "success": true,
        "data": {
            "id": 5,
            "company_id": 123,
            "owner_id": {
                "id": 123,
                "name": "Person",
                "email": "person@launchscout.com",
                "has_pic": 0,
                "pic_hash": null,
                "active_flag": true,
                "value": 17120881
            },
            "name": "Org",
            "open_deals_count": 0,
            "related_open_deals_count": 0,
            "closed_deals_count": 0,
            "related_closed_deals_count": 0,
            "email_messages_count": 0,
            "people_count": 0,
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
            "category_id": null,
            "picture_id": null,
            "country_code": null,
            "first_char": "s",
            "update_time": "2023-02-20 20:23:09",
            "delete_time": null,
            "add_time": "2023-02-15 16:20:48",
            "visible_to": "3",
            "next_activity_date": null,
            "next_activity_time": null,
            "next_activity_id": null,
            "last_activity_id": null,
            "last_activity_date": null,
            "label": null,
            "address": null,
            "address_subpremise": null,
            "address_street_number": null,
            "address_route": null,
            "address_sublocality": null,
            "address_locality": null,
            "address_admin_area_level_1": null,
            "address_admin_area_level_2": null,
            "address_country": null,
            "address_postal_code": null,
            "address_formatted_address": null,
            "cc_email": "launchscout-sandbox@pipedrivemail.com",
            "74297017034377900b80ebbeb37c7c45921b278f": "20",
            "93fc28f7d5aee87fc6484441cab648760a6c0d2d": "Elixir"
        },
        "related_objects": {
            "user": {
                "123": {
                    "id": 123,
                    "name": "Person",
                    "email": "person@launchscout.com",
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

  def handle_list_organizations(conn, _) do
    response_body = ~s"""
      {
        "success": true,
        "data": [
          {
            "id": 1,
            "company_id": 23434234,
            "owner_id": {
              "id": 243543625,
              "name": "Batman",
              "email": "batman@example",
              "has_pic": 0,
              "pic_hash": null,
              "active_flag": true,
              "value": 44536
            },
            "name": "ACME Co",
            "open_deals_count": 3,
            "related_open_deals_count": 0,
            "closed_deals_count": 0,
            "related_closed_deals_count": 0,
            "email_messages_count": 0,
            "people_count": 1,
            "activities_count": 10,
            "done_activities_count": 10,
            "undone_activities_count": 0,
            "files_count": 0,
            "notes_count": 3,
            "followers_count": 1,
            "won_deals_count": 0,
            "related_won_deals_count": 0,
            "lost_deals_count": 0,
            "related_lost_deals_count": 0,
            "active_flag": true,
            "category_id": null,
            "picture_id": null,
            "country_code": null,
            "first_char": "m",
            "update_time": "2023-02-24 20:55:35",
            "delete_time": null,
            "add_time": "2022-07-09 15:16:26",
            "visible_to": "3",
            "next_activity_date": "2024-05-06",
            "next_activity_time": "11:22:33",
            "next_activity_id": null,
            "last_activity_id": 2,
            "last_activity_date": "2030-10-01",
            "label": null,
            "address": null,
            "address_subpremise": null,
            "address_street_number": null,
            "address_route": null,
            "address_sublocality": null,
            "address_locality": null,
            "address_admin_area_level_1": null,
            "address_admin_area_level_2": null,
            "address_country": null,
            "address_postal_code": null,
            "address_formatted_address": null,
            "owner_name": "Batman",
            "3671213bcab78a65d5c676ac224b05b6290": "TagOfSomeKind",
            "cc_email": "checkitout@pipedrivemail.com"
          },
          {
            "id": 2,
            "company_id": 34346345,
            "owner_id": {
              "id": 43634534,
              "name": "Robin",
              "email": "robin@example",
              "has_pic": 0,
              "pic_hash": null,
              "active_flag": true,
              "value": 46345564
            },
            "name": "Wayne Enterprises",
            "open_deals_count": 0,
            "related_open_deals_count": 0,
            "closed_deals_count": 0,
            "related_closed_deals_count": 0,
            "email_messages_count": 0,
            "people_count": 1,
            "activities_count": 0,
            "done_activities_count": 0,
            "undone_activities_count": 0,
            "files_count": 0,
            "notes_count": 2,
            "followers_count": 1,
            "won_deals_count": 0,
            "related_won_deals_count": 0,
            "lost_deals_count": 0,
            "related_lost_deals_count": 0,
            "active_flag": true,
            "category_id": null,
            "picture_id": null,
            "country_code": null,
            "first_char": "l",
            "update_time": "2023-03-06 18:23:59",
            "delete_time": null,
            "add_time": "2022-08-11 15:44:35",
            "visible_to": "3",
            "next_activity_date": null,
            "next_activity_time": null,
            "next_activity_id": null,
            "last_activity_id": null,
            "last_activity_date": null,
            "label": null,
            "address": null,
            "address_subpremise": null,
            "address_street_number": null,
            "address_route": null,
            "address_sublocality": null,
            "address_locality": null,
            "address_admin_area_level_1": null,
            "address_admin_area_level_2": null,
            "address_country": null,
            "address_postal_code": null,
            "address_formatted_address": null,
            "owner_name": "Robin",
            "3671213bcab78a65d5c676ac224b05b6290": "Some, Other, Tags",
            "cc_email": "checkitout@pipedrivemail.com"
          }
        ],
        "additional_data": {
          "pagination": {
            "start": 0,
            "limit": 2,
            "more_items_in_collection": true,
            "next_start": 2
          }
        },
        "related_objects": {
          "user": {
            "243543625": {
              "id": 243543625,
              "name": "Batman",
              "email": "batman@example",
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

  def handle_search_organizations(conn, %{"term" => _term}) do
    response_body = ~s"""
    {
      "success": true,
      "data": {
          "items": [
              {
                  "result_score": 0.35513002,
                  "item": {
                      "id": 2,
                      "type": "organization",
                      "name": "Great Amazing Organization",
                      "address": null,
                      "visible_to": 3,
                      "owner": {
                          "id": 17269766
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
end
