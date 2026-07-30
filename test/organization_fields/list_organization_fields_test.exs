defmodule ExPipedrive.Organizations.ListOrganizationFieldsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Field
  alias ExPipedrive.OrganizationFields
  alias ExPipedrive.Page

  describe "list_organization_fields" do
    test "returns API v2 organization field definitions as a cursor page", %{client: client} do
      assert {:ok,
              %Page{
                next_cursor: nil,
                data: [
                  _,
                  %Field{
                    field_code: "organization_custom_hash",
                    field_name: "Organization tier",
                    key: "organization_custom_hash",
                    name: "Organization tier",
                    field_type: "enum"
                  }
                ]
              }} = OrganizationFields.list_organization_fields(client)
    end
  end
end
