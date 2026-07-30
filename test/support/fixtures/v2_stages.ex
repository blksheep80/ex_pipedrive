defmodule ExPipedrive.Fixtures.V2Stages do
  @moduledoc false

  def stage(id \\ 1) do
    %{
      "id" => id,
      "order_nr" => id,
      "name" => "Qualified",
      "is_deleted" => false,
      "deal_probability" => 100,
      "pipeline_id" => 1,
      "is_deal_rot_enabled" => true,
      "days_to_rotten" => 14,
      "add_time" => "2024-01-01T00:00:00Z",
      "update_time" => "2024-01-01T00:00:00Z"
    }
  end

  def get_response(id \\ 1) do
    %{"success" => true, "data" => stage(id)}
  end

  def list_response(cursor \\ nil) do
    {data, next_cursor} =
      case cursor do
        nil -> {[stage(1), stage(2)], "stages-page-2"}
        "stages-page-2" -> {[stage(3)], nil}
        _ -> {[], nil}
      end

    %{
      "success" => true,
      "data" => data,
      "additional_data" => %{"next_cursor" => next_cursor}
    }
  end

  def create_response(attrs) when is_map(attrs) do
    base = stage(99)

    data =
      Map.merge(base, %{
        "name" => Map.get(attrs, "name", base["name"]),
        "pipeline_id" => Map.get(attrs, "pipeline_id", base["pipeline_id"]),
        "deal_probability" => Map.get(attrs, "deal_probability", base["deal_probability"]),
        "is_deal_rot_enabled" =>
          Map.get(attrs, "is_deal_rot_enabled", base["is_deal_rot_enabled"]),
        "days_to_rotten" => Map.get(attrs, "days_to_rotten", base["days_to_rotten"])
      })

    %{"success" => true, "data" => data}
  end

  def update_response(id, attrs) when is_map(attrs) do
    %{"success" => true, "data" => Map.merge(stage(id), attrs)}
  end

  def delete_response(id) do
    %{"success" => true, "data" => %{"id" => id}}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-#{status}"}
  end
end
