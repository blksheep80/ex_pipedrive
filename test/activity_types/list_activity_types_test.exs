defmodule ExPipedrive.ActivityTypes.ListActivityTypesTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.ActivityType
  alias ExPipedrive.ActivityTypes

  describe "list_activity_types" do
    test "it forms a correct request and returns a list of activity types", %{client: client} do
      assert {:ok, [%ActivityType{name: "Call"} | _]} = ActivityTypes.list_activity_types(client)
    end
  end
end
