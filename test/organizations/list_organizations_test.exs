defmodule ExPipedrive.Organizations.OrganizationsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.{
    Organization,
    Organizations,
    PagedResult
  }

  describe "list_organizations" do
    test "it forms a correct request and returns a list of organizations", %{client: client} do
      assert {:ok,
              %PagedResult{
                success: true,
                additional_data: %{
                  pagination: %{more_items_in_collection: true, start: 0, limit: 2}
                },
                data: [
                  %Organization{
                    name: "ACME Co",
                    id: 1,
                    company_id: 23_434_234,
                    open_deals_count: 3,
                    related_open_deals_count: 0,
                    closed_deals_count: 0,
                    related_closed_deals_count: 0,
                    email_messages_count: 0,
                    people_count: 1,
                    activities_count: 10,
                    done_activities_count: 10,
                    undone_activities_count: 0,
                    files_count: 0,
                    notes_count: 3,
                    followers_count: 1,
                    won_deals_count: 0,
                    related_won_deals_count: 0,
                    lost_deals_count: 0,
                    related_lost_deals_count: 0,
                    active_flag: true,
                    category_id: nil,
                    picture_id: nil,
                    country_code: nil,
                    first_char: "m",
                    update_time: ~N[2023-02-24 20:55:35],
                    delete_time: nil,
                    add_time: ~N[2022-07-09 15:16:26],
                    visible_to: 3,
                    is_deleted: false,
                    owner_id: 44_536,
                    next_activity_date: ~D[2024-05-06],
                    next_activity_time: ~T[11:22:33],
                    next_activity_id: nil,
                    last_activity_id: 2,
                    last_activity_date: ~D[2030-10-01],
                    label: nil,
                    address: nil,
                    address_subpremise: nil,
                    address_street_number: nil,
                    address_route: nil,
                    address_sublocality: nil,
                    address_locality: nil,
                    address_admin_area_level_1: nil,
                    address_admin_area_level_2: nil,
                    address_country: nil,
                    address_postal_code: nil,
                    address_formatted_address: nil,
                    owner_name: "Batman",
                    cc_email: "checkitout@pipedrivemail.com"
                  }
                  | _
                ]
              }} = Organizations.list_organizations(client)
    end
  end
end
