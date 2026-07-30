defmodule ExPipedrive.Notes.GetAllNotesTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.{
    Note,
    Notes
  }

  describe "get_all_org_notes" do
    test "it forms a correct request and returns the correct data structure results for matching notes",
         %{client: client} do
      assert {:ok,
              [
                %Note{
                  id: 2,
                  org_id: 1,
                  content: "Met them at such and such event",
                  pinned_to_organization_flag: true
                },
                %Note{
                  id: 1,
                  org_id: 1,
                  content: "Talked with them and they told me they are using elixir",
                  pinned_to_organization_flag: false
                }
              ]} = Notes.get_all_org_notes(client, org_id: 1)
    end
  end
end
