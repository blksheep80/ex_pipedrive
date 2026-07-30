defmodule ExPipedrive.Fixtures.V2Activities do
  @moduledoc false

  @custom_fields %{
    "53c2f18db6a1655d6af8bba77d9679565f975fd8" => "Follow-up"
  }

  def activity(id \\ 1) do
    %{
      "id" => id,
      "subject" => "Call Mecklem, LLC",
      "type" => "call",
      "owner_id" => 15_783_886,
      "deal_id" => 1,
      "person_id" => 1,
      "org_id" => 1,
      "lead_id" => nil,
      "project_id" => nil,
      "due_date" => "2024-03-20",
      "due_time" => "10:00",
      "duration" => "01:00",
      "busy" => true,
      "done" => false,
      "priority" => 1,
      "note" => "Discuss renewal",
      "public_description" => "Public description",
      "location" => %{
        "value" => "123 Main St, Cincinnati, OH 45202",
        "country" => "US",
        "admin_area_level_1" => "OH",
        "locality" => "Cincinnati",
        "postal_code" => "45202",
        "route" => "Main St",
        "street_number" => "123"
      },
      "participants" => [
        %{"person_id" => 1, "primary" => true}
      ],
      "attendees" => [],
      "add_time" => "2024-03-20T09:00:00Z",
      "update_time" => "2024-03-20T09:00:00Z",
      "marked_as_done_time" => nil,
      "is_deleted" => false,
      "custom_fields" => @custom_fields
    }
  end

  def get_response(id \\ 1) do
    %{"success" => true, "data" => activity(id)}
  end

  def list_response(cursor \\ nil) do
    {data, next_cursor} =
      case cursor do
        nil -> {[activity(1), activity(2)], "activities-page-2"}
        "activities-page-2" -> {[activity(3)], nil}
        _ -> {[], nil}
      end

    %{
      "success" => true,
      "data" => data,
      "additional_data" => %{"next_cursor" => next_cursor}
    }
  end

  def create_response(attrs) when is_map(attrs) do
    base = activity(99)

    data =
      base
      |> Map.merge(
        Map.take(attrs, [
          "subject",
          "type",
          "owner_id",
          "deal_id",
          "person_id",
          "org_id",
          "lead_id",
          "project_id",
          "due_date",
          "due_time",
          "duration",
          "busy",
          "done",
          "priority",
          "note",
          "public_description",
          "participants",
          "attendees",
          "custom_fields"
        ])
      )
      |> maybe_merge_location(attrs)

    %{"success" => true, "data" => data}
  end

  def update_response(id, attrs) when is_map(attrs) do
    data =
      id
      |> activity()
      |> Map.merge(Map.drop(attrs, ["location"]))
      |> maybe_merge_location(attrs)

    %{"success" => true, "data" => data}
  end

  def delete_response(id) do
    %{"success" => true, "data" => %{"id" => id}}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-#{status}"}
  end

  defp maybe_merge_location(data, %{"location" => location}) when is_binary(location) do
    Map.put(data, "location", %{"value" => location})
  end

  defp maybe_merge_location(data, %{"location" => location}) when is_map(location) do
    Map.put(data, "location", location)
  end

  defp maybe_merge_location(data, _), do: data
end
