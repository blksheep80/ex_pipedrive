defmodule ExPipedrive.ActivityFields.ListActivityFieldsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.ActivityFields
  alias ExPipedrive.Field
  alias ExPipedrive.FieldOption
  alias ExPipedrive.Fields
  alias ExPipedrive.Page

  describe "list_activity_fields" do
    test "returns API v2 activity field definitions as a cursor page", %{client: client} do
      assert {:ok,
              %Page{
                next_cursor: nil,
                data: [
                  _,
                  %Field{
                    field_code: "activity_custom_hash",
                    field_name: "Activity tier",
                    key: "activity_custom_hash",
                    name: "Activity tier",
                    field_type: "enum",
                    options: [
                      %FieldOption{id: 21, label: "Gold"},
                      %FieldOption{id: 22, label: "Silver"}
                    ]
                  }
                ]
              } = page} = ActivityFields.list_activity_fields(client)

      assert {:ok, "activity_custom_hash"} = Fields.key_for(page, "Activity tier")
      assert {:ok, "Activity tier"} = Fields.label_for(page, "activity_custom_hash")
    end
  end
end
