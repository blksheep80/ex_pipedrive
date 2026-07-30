defmodule ExPipedrive.Persons.ListPersonFieldsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Field
  alias ExPipedrive.FieldOption
  alias ExPipedrive.Page
  alias ExPipedrive.PersonFields

  describe "list_person_fields" do
    test "returns API v2 person field definitions as a cursor page", %{client: client} do
      assert {:ok,
              %Page{
                next_cursor: nil,
                data: [
                  _,
                  %Field{
                    field_code: "person_custom_hash",
                    field_name: "Person tier",
                    key: "person_custom_hash",
                    name: "Person tier",
                    field_type: "enum",
                    options: [
                      %FieldOption{id: 21, label: "Gold"},
                      %FieldOption{id: 22, label: "Silver"}
                    ]
                  }
                ]
              }} = PersonFields.list_person_fields(client)
    end
  end
end
