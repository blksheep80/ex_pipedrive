defmodule ExPipedrive.Activities.AddActivityTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Activities
  alias ExPipedrive.Activity

  describe "add_activity" do
    test "it forms a correct request and returns an added activity", %{client: client} do
      expected_attributes = %{
        due_date: ~D[2022-07-10],
        due_time: "01:04",
        deal_id: 50,
        person_id: 1,
        org_id: 1,
        note: "This is a note",
        location: "location",
        public_description: "This is a public description",
        subject: "This is the subject",
        type: "Call",
        user_id: 15_783_886,
        busy_flag: true,
        done: 0
      }

      unsaved_activity = Activity.new(expected_attributes)

      assert {:ok, %Activity{id: 2}} = Activities.add_activity(client, unsaved_activity)
    end
  end
end
