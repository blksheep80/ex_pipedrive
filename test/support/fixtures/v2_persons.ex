defmodule ExPipedrive.Fixtures.V2Persons do
  @moduledoc false

  @custom_fields %{
    "53c2f18db6a1655d6af8bba77d9679565f975fd8" => "VIP"
  }

  def person(id \\ 1) do
    %{
      "id" => id,
      "name" => "Tim Mecklem",
      "first_name" => "Tim",
      "last_name" => "Mecklem",
      "owner_id" => 15_783_886,
      "org_id" => 1,
      "add_time" => "2022-07-09T15:16:26Z",
      "update_time" => "2023-02-22T22:05:25Z",
      "is_deleted" => false,
      "visible_to" => 3,
      "label_ids" => [],
      "emails" => [
        %{"label" => "work", "value" => "tim@launchscout.com", "primary" => true}
      ],
      "phones" => [
        %{"value" => "", "primary" => true}
      ],
      "custom_fields" => @custom_fields
    }
  end

  def get_response(id \\ 1) do
    %{"success" => true, "data" => person(id)}
  end

  def list_response(cursor \\ nil) do
    {data, next_cursor} =
      case cursor do
        nil -> {[person(1), person(2)], "persons-page-2"}
        "persons-page-2" -> {[person(3)], nil}
        _ -> {[], nil}
      end

    %{
      "success" => true,
      "data" => data,
      "additional_data" => %{"next_cursor" => next_cursor}
    }
  end

  def create_response(attrs) when is_map(attrs) do
    base = person(99)
    data = Map.merge(base, Map.take(attrs, ["name", "owner_id", "org_id", "emails", "phones"]))
    %{"success" => true, "data" => data}
  end

  def update_response(id, attrs) when is_map(attrs) do
    %{"success" => true, "data" => Map.merge(person(id), attrs)}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-#{status}"}
  end
end
