defmodule ExPipedrive.Persons.ListPersonFieldsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Field
  alias ExPipedrive.FieldOption
  alias ExPipedrive.PagedResult
  alias ExPipedrive.PersonFields

  describe "list_person_fields" do
    test "it forms a correct request and returns a list of person field objects", %{
      client: client
    } do
      assert {:ok,
              %PagedResult{
                success: true,
                additional_data: %{
                  pagination: %{more_items_in_collection: false, start: 0, limit: 2}
                },
                data: [
                  _,
                  %Field{
                    id: 9064,
                    key: "8a9fba4ea88bbe2bde6a32efa89960fbdb4f8c71",
                    name: "Things",
                    order_nr: 1,
                    field_type: "set",
                    json_column_flag: true,
                    add_time: ~N[2023-03-20 20:00:12],
                    update_time: ~N[2023-03-20 20:00:11],
                    last_updated_by_user_id: 11_276_935,
                    edit_flag: true,
                    details_visible_flag: true,
                    add_visible_flag: false,
                    important_flag: true,
                    bulk_edit_allowed: true,
                    filtering_allowed: true,
                    sortable_flag: true,
                    searchable_flag: true,
                    active_flag: true,
                    mandatory_flag: false,
                    options: [
                      %FieldOption{
                        id: 21,
                        label: "good"
                      },
                      %FieldOption{
                        id: 22,
                        label: "bad"
                      },
                      %FieldOption{
                        id: 23,
                        label: "indifferent"
                      }
                    ]
                  }
                ]
              }} = PersonFields.list_person_fields(client)
    end
  end
end
