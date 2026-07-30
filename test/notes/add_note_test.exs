defmodule ExPipedrive.Notes.AddNoteTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.{
    Note,
    Notes
  }

  describe "add_note" do
    test "it forms a correct request and returns an added note", %{client: client} do
      expected_attributes = %{
        content: "Met them at such and such event",
        org_id: 1,
        pinned_to_organization_flag: true
      }

      unsaved_note = Note.new(expected_attributes)

      assert {:ok,
              %Note{
                id: 1,
                content: "Met them at such and such event",
                org_id: 1,
                pinned_to_organization_flag: true
              }} = Notes.add_note(client, unsaved_note)
    end

    test "accepts map attributes through the create alias", %{client: client} do
      assert {:ok,
              %Note{
                id: 1,
                content: "Met them at such and such event",
                org_id: 1,
                pinned_to_organization_flag: true
              }} =
               Notes.create(client, %{
                 content: "Met them at such and such event",
                 org_id: 1,
                 pinned_to_organization_flag: true
               })
    end
  end
end
