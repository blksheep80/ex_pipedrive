defmodule ExPipedrive.Fixtures.V1LeadFields do
  @moduledoc false

  def list_response(start \\ "0", limit \\ "500") do
    start = String.to_integer(start)
    limit = String.to_integer(limit)

    fields = [
      %{
        "id" => 12_501,
        "key" => "id",
        "name" => "ID",
        "order_nr" => 0,
        "field_type" => "int",
        "json_column_flag" => false,
        "add_time" => "2022-07-08 12:08:35",
        "update_time" => "2022-07-08 12:08:35",
        "last_updated_by_user_id" => nil,
        "edit_flag" => false,
        "details_visible_flag" => false,
        "add_visible_flag" => false,
        "important_flag" => false,
        "bulk_edit_allowed" => false,
        "filtering_allowed" => true,
        "sortable_flag" => true,
        "searchable_flag" => false,
        "active_flag" => true,
        "mandatory_flag" => true
      },
      %{
        "id" => 12_502,
        "key" => "lead_custom_hash",
        "name" => "Lead tier",
        "order_nr" => 1,
        "field_type" => "enum",
        "json_column_flag" => true,
        "add_time" => "2023-08-24 15:37:24",
        "update_time" => "2023-08-24 15:37:24",
        "last_updated_by_user_id" => 15_783_886,
        "edit_flag" => true,
        "details_visible_flag" => true,
        "add_visible_flag" => true,
        "important_flag" => false,
        "bulk_edit_allowed" => true,
        "filtering_allowed" => true,
        "sortable_flag" => true,
        "searchable_flag" => true,
        "active_flag" => true,
        "options" => [
          %{"id" => 31, "label" => "Hot"},
          %{"id" => 32, "label" => "Warm"}
        ],
        "mandatory_flag" => false
      }
    ]

    page_fields = Enum.slice(fields, start, limit)
    next_start = start + length(page_fields)
    more? = next_start < length(fields)

    %{
      "success" => true,
      "data" => page_fields,
      "additional_data" => %{
        "pagination" => %{
          "start" => start,
          "limit" => limit,
          "more_items_in_collection" => more?
        }
      }
    }
  end
end
