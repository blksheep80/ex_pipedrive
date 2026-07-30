defmodule ExPipedrive.Organizations.ListOrganizationFieldsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Field
  alias ExPipedrive.OrganizationFields
  alias ExPipedrive.PagedResult

  describe "list_organization_fields" do
    test "it forms a correct request and returns a list of organization field objects", %{
      client: client
    } do
      assert {:ok,
              %PagedResult{
                success: true,
                additional_data: %{
                  pagination: %{more_items_in_collection: false, start: 0, limit: 500}
                },
                data: [
                  _,
                  %Field{
                    id: 4024,
                    key: "93fc28f7d5aee87fc6484441cab648760a6c0d2d",
                    name: "Tech Stack",
                    order_nr: 23,
                    field_type: "varchar",
                    json_column_flag: true,
                    add_time: ~N[2023-02-15 16:36:27],
                    update_time: ~N[2023-02-15 16:36:26],
                    last_updated_by_user_id: 1,
                    edit_flag: true,
                    details_visible_flag: true,
                    add_visible_flag: true,
                    important_flag: true,
                    bulk_edit_allowed: true,
                    filtering_allowed: true,
                    sortable_flag: true,
                    searchable_flag: true,
                    active_flag: true,
                    index_visible_flag: true,
                    mandatory_flag: false
                  }
                ]
              }} = OrganizationFields.list_organization_fields(client)
    end
  end
end
