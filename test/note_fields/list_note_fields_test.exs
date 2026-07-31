defmodule ExPipedrive.NoteFields.ListNoteFieldsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Field
  alias ExPipedrive.FieldOption
  alias ExPipedrive.NoteFields

  describe "list_note_fields" do
    test "returns API v1 note field definitions", %{client: client} do
      assert {:ok,
              [
                _,
                %Field{
                  field_code: "b7c4e2a1f9038d5e6a2b1c0d9e8f7a6b5c4d3e2",
                  field_name: "Note category",
                  key: "b7c4e2a1f9038d5e6a2b1c0d9e8f7a6b5c4d3e2",
                  name: "Note category",
                  field_type: "enum",
                  options: [
                    %FieldOption{id: 31, label: "Follow-up"},
                    %FieldOption{id: 32, label: "Internal"}
                  ]
                }
              ]} = NoteFields.list_note_fields(client)
    end
  end
end
