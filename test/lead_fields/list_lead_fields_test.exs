defmodule ExPipedrive.LeadFields.ListLeadFieldsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Field
  alias ExPipedrive.FieldOption
  alias ExPipedrive.Fields
  alias ExPipedrive.LeadFields
  alias ExPipedrive.PagedResult

  describe "list/2" do
    test "returns API v1 lead field definitions as a paged result", %{client: client} do
      assert {:ok,
              %PagedResult{
                data: [
                  %Field{key: "id", name: "ID", field_type: "int"},
                  %Field{
                    key: "lead_custom_hash",
                    name: "Lead tier",
                    field_type: "enum",
                    options: [
                      %FieldOption{id: 31, label: "Hot"},
                      %FieldOption{id: 32, label: "Warm"}
                    ]
                  }
                ],
                additional_data: %{pagination: pagination}
              }} = LeadFields.list(client)

      assert %{start: 0, limit: 500, more_items_in_collection: false} = pagination
    end

    test "Fields.resolve/2 works on the paged result", %{client: client} do
      assert {:ok, page} = LeadFields.list(client)
      assert {:ok, "lead_custom_hash"} = Fields.key_for(page, "Lead tier")
      assert {:ok, "Lead tier"} = Fields.label_for(page, "lead_custom_hash")
    end
  end

  describe "stream/2" do
    test "streams all lead fields across offset pages", %{client: client} do
      fields =
        client
        |> LeadFields.stream(limit: 1)
        |> Enum.to_list()

      assert length(fields) == 2
      assert Enum.at(fields, 1).name == "Lead tier"
    end
  end
end
