defmodule ExPipedrive.Notes.GetNoteTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{Note, Notes}

  describe "get_note" do
    test "fetches a note through the explicit v1 route", %{client: client} do
      assert {:ok,
              %Note{
                id: 1,
                content: "Met them at such and such event",
                org_id: 1,
                pinned_to_organization_flag: true
              }} = Notes.get_note(client, 1)
    end

    test "provides the v1 get alias", %{client: client} do
      assert {:ok, %Note{id: 1}} = Notes.get(client, 1)
    end
  end
end
