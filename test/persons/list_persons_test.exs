defmodule ExPipedrive.Persons.ListPersonsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.PagedResult
  alias ExPipedrive.Person
  alias ExPipedrive.Persons

  describe "list_persons" do
    test "it forms a correct request and returns a list of person objects", %{client: client} do
      assert {:ok,
              %PagedResult{
                success: true,
                additional_data: %{
                  pagination: %{more_items_in_collection: true, start: 0, limit: 2}
                },
                data: [
                  %Person{
                    id: 1,
                    company_id: 11_796_774,
                    owner_id: 15_783_886,
                    org_id: 1,
                    name: "Tim Mecklem",
                    first_name: "Tim",
                    last_name: "Mecklem",
                    open_deals_count: 3,
                    related_open_deals_count: 0,
                    closed_deals_count: 5,
                    related_closed_deals_count: 2,
                    participant_open_deals_count: 0,
                    participant_closed_deals_count: 0,
                    email_messages_count: 0,
                    activities_count: 19,
                    done_activities_count: 14,
                    undone_activities_count: 5,
                    files_count: 0,
                    notes_count: 0,
                    followers_count: 1,
                    won_deals_count: 0,
                    related_won_deals_count: 0,
                    lost_deals_count: 0,
                    related_lost_deals_count: 0,
                    active_flag: true,
                    update_time: ~N[2023-02-22 22:05:25],
                    delete_time: nil,
                    add_time: ~N[2022-07-09 15:16:26],
                    visible_to: "3",
                    next_activity_date: ~D[2022-07-20],
                    next_activity_time: nil,
                    next_activity_id: 5,
                    last_activity_id: 2,
                    last_activity_date: ~D[2030-10-01],
                    last_incoming_mail_time: nil,
                    last_outgoing_mail_time: ~N[2022-08-19 19:13:53],
                    label: nil,
                    org_name: "Mecklem, LLC",
                    owner_name: "Tim Mecklem",
                    primary_email: "tim@launchscout.com"
                  }
                  | _
                ]
              }} = Persons.list_persons(client)
    end
  end
end
