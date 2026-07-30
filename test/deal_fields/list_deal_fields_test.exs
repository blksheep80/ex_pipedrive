defmodule ExPipedrive.DealFields.ListDealFieldsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.DealFields
  alias ExPipedrive.Field
  alias ExPipedrive.FieldOption
  alias ExPipedrive.PagedResult

  describe "list_deal_fields" do
    test "it forms a correct request and returns a list of deal field objects", %{
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
                    id: 12_488,
                    key: "a31aaf5e2c4843027e1e183d7001686afb9781d0",
                    name: "swat",
                    order_nr: 1,
                    field_type: "set",
                    json_column_flag: true,
                    add_time: ~N[2023-08-24 15:37:24],
                    update_time: ~N[2023-08-24 15:37:24],
                    last_updated_by_user_id: 15_783_886,
                    edit_flag: true,
                    details_visible_flag: true,
                    add_visible_flag: true,
                    important_flag: false,
                    bulk_edit_allowed: true,
                    filtering_allowed: true,
                    sortable_flag: true,
                    searchable_flag: true,
                    active_flag: true,
                    mandatory_flag: false,
                    options: [
                      %FieldOption{
                        id: 25,
                        label: "or not"
                      },
                      %FieldOption{
                        id: 26,
                        label: ", akond of"
                      }
                    ]
                  }
                ]
              }} = DealFields.list_deal_fields(client)
    end
  end
end
