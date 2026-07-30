defmodule ExPipedrive.Activities.ListOwnActivitiesTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Activities
  alias ExPipedrive.Activity
  alias ExPipedrive.PagedResult

  describe "list_own_activities/2" do
    test "returns a list of activities for the authenticated user", %{client: client} do
      {:ok, %PagedResult{success: true, data: [activity | _]} = result} =
        Activities.list_own_activities(client)

      assert result.success == true
      assert %Activity{} = activity
      assert activity.subject == "Own Activity"
      assert activity.public_description == "Own activity description"
    end

    test "accepts pagination parameters", %{client: client} do
      {:ok, %PagedResult{additional_data: additional_data}} =
        Activities.list_own_activities(client, limit: 50, start: 10)

      assert additional_data.pagination.limit == 50
      assert additional_data.pagination.start == 10
      assert additional_data.pagination.more_items_in_collection == false
    end

    test "accepts filtering parameters", %{client: client} do
      {:ok, %PagedResult{}} = Activities.list_own_activities(client, done: true, type: "call")
    end

    test "accepts date range parameters", %{client: client} do
      start_date = "2024-03-01"
      end_date = "2024-03-31"

      {:ok, %PagedResult{data: [activity]}} =
        Activities.list_own_activities(client, start_date: start_date, end_date: end_date)

      assert activity.due_date == ~D[2024-03-01]
    end

    test "accepts start_date parameter only", %{client: client} do
      start_date = "2024-03-01"

      {:ok, %PagedResult{data: [activity]}} =
        Activities.list_own_activities(client, start_date: start_date)

      assert activity.due_date == ~D[2024-03-01]
    end
  end
end
