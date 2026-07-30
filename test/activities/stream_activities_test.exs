defmodule ExPipedrive.Activities.StreamActivitiesTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Activities
  alias ExPipedrive.Activity
  alias ExPipedrive.Page

  describe "list_activities_page/2" do
    test "returns a Page wrapper with next_cursor", %{client: client} do
      assert {:ok, %Page{data: activities, next_cursor: "activities-page-2"}} =
               Activities.list_activities_page(client, limit: 100)

      assert Enum.map(activities, & &1.id) == [1, 2]
      assert Enum.all?(activities, &match?(%Activity{}, &1))
    end

    test "returns the final page when cursor is exhausted", %{client: client} do
      assert {:ok, %Page{data: activities, next_cursor: nil}} =
               Activities.list_activities_page(client, cursor: "activities-page-2")

      assert Enum.map(activities, & &1.id) == [3]
      assert Page.done?(%Page{data: activities, next_cursor: nil})
    end
  end

  describe "stream_activities/2" do
    test "auto-follows cursors until exhausted", %{client: client} do
      activities = client |> Activities.stream_activities(limit: 100) |> Enum.to_list()

      assert Enum.map(activities, & &1.id) == [1, 2, 3]
      assert Enum.all?(activities, &match?(%Activity{}, &1))
    end
  end
end
