defmodule ExPipedrive.ProductFields.ListProductFieldsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Field
  alias ExPipedrive.FieldOption
  alias ExPipedrive.Fields
  alias ExPipedrive.Page
  alias ExPipedrive.ProductFields

  describe "list_product_fields" do
    test "returns API v2 product field definitions as a cursor page", %{client: client} do
      assert {:ok,
              %Page{
                next_cursor: nil,
                data: [
                  _,
                  %Field{
                    field_code: "product_custom_hash",
                    field_name: "Product tier",
                    key: "product_custom_hash",
                    name: "Product tier",
                    field_type: "enum",
                    options: [
                      %FieldOption{id: 21, label: "Gold"},
                      %FieldOption{id: 22, label: "Silver"}
                    ]
                  }
                ]
              } = page} = ProductFields.list_product_fields(client)

      assert {:ok, "product_custom_hash"} = Fields.key_for(page, "Product tier")
      assert {:ok, "Product tier"} = Fields.label_for(page, "product_custom_hash")
    end
  end
end
