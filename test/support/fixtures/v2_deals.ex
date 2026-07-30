defmodule ExPipedrive.Fixtures.V2Deals do
  @moduledoc false

  @custom_fields %{
    "53c2f18db6a1655d6af8bba77d9679565f975fd8" => "Text Custom Field",
    "d4de1c1518b4531717c676029a45911c340390a6" => %{
      "value" => 2300,
      "currency" => "EUR"
    }
  }

  def deal(id \\ 1) do
    %{
      "id" => id,
      "title" => "Mecklem, LLC deal",
      "value" => 30_000.0,
      "currency" => "USD",
      "creator_user_id" => 15_783_886,
      "person_id" => 1,
      "org_id" => 1,
      "stage_id" => 2,
      "pipeline_id" => 1,
      "add_time" => "2022-07-09T15:16:27Z",
      "update_time" => "2022-07-09T15:16:27Z",
      "stage_change_time" => nil,
      "status" => "open",
      "probability" => nil,
      "lost_reason" => nil,
      "visible_to" => 3,
      "close_time" => nil,
      "won_time" => nil,
      "lost_time" => nil,
      "expected_close_date" => "2022-07-21",
      "owner_id" => 15_783_886,
      "label_ids" => [],
      "is_deleted" => false,
      "custom_fields" => @custom_fields
    }
  end

  def get_response(id \\ 1) do
    %{"success" => true, "data" => deal(id)}
  end

  def list_response(cursor \\ nil) do
    {data, next_cursor} =
      case cursor do
        nil -> {[deal(1), deal(2)], "cursor-page-2"}
        "cursor-page-2" -> {[deal(3)], nil}
        _ -> {[], nil}
      end

    %{
      "success" => true,
      "data" => data,
      "additional_data" => %{"next_cursor" => next_cursor}
    }
  end

  def create_response(attrs) when is_map(attrs) do
    base = deal(99)

    data =
      base
      |> Map.merge(%{
        "title" => Map.get(attrs, "title", base["title"]),
        "person_id" => Map.get(attrs, "person_id", base["person_id"]),
        "org_id" => Map.get(attrs, "org_id", base["org_id"]),
        "value" => Map.get(attrs, "value", base["value"]),
        "currency" => Map.get(attrs, "currency", base["currency"]),
        "status" => Map.get(attrs, "status", base["status"])
      })

    %{"success" => true, "data" => data}
  end

  def update_response(id, attrs) when is_map(attrs) do
    %{"success" => true, "data" => Map.merge(deal(id), attrs)}
  end

  def delete_response(id) do
    %{"success" => true, "data" => %{"id" => id}}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-#{status}"}
  end
end
