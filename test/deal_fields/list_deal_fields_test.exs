defmodule ExPipedrive.DealFields.ListDealFieldsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.DealFields
  alias ExPipedrive.Field
  alias ExPipedrive.FieldOption
  alias ExPipedrive.Page

  describe "list_deal_fields" do
    test "returns API v2 deal field definitions as a cursor page", %{client: client} do
      assert {:ok,
              %Page{
                next_cursor: nil,
                data: [
                  _,
                  %Field{
                    field_code: "deal_custom_hash",
                    field_name: "Deal tier",
                    key: "deal_custom_hash",
                    name: "Deal tier",
                    field_type: "enum",
                    options: [
                      %FieldOption{id: 21, label: "Gold"},
                      %FieldOption{id: 22, label: "Silver"}
                    ]
                  }
                ]
              }} = DealFields.list_deal_fields(client)
    end
  end
end
