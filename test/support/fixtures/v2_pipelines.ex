defmodule ExPipedrive.Fixtures.V2Pipelines do
  @moduledoc false

  def pipeline(id \\ 1) do
    %{
      "id" => id,
      "name" => "Pipeline",
      "order_nr" => id,
      "is_deleted" => false,
      "is_deal_probability_enabled" => true,
      "add_time" => "2024-01-01T00:00:00Z",
      "update_time" => "2024-01-01T00:00:00Z"
    }
  end

  def get_response(id \\ 1) do
    %{"success" => true, "data" => pipeline(id)}
  end

  def list_response(cursor \\ nil) do
    {data, next_cursor} =
      case cursor do
        nil -> {[pipeline(1), pipeline(2)], "pipelines-page-2"}
        "pipelines-page-2" -> {[pipeline(3)], nil}
        _ -> {[], nil}
      end

    %{
      "success" => true,
      "data" => data,
      "additional_data" => %{"next_cursor" => next_cursor}
    }
  end

  def create_response(attrs) when is_map(attrs) do
    base = pipeline(99)

    data =
      Map.merge(base, %{
        "name" => Map.get(attrs, "name", base["name"]),
        "is_deal_probability_enabled" =>
          Map.get(attrs, "is_deal_probability_enabled", base["is_deal_probability_enabled"])
      })

    %{"success" => true, "data" => data}
  end

  def update_response(id, attrs) when is_map(attrs) do
    %{"success" => true, "data" => Map.merge(pipeline(id), attrs)}
  end

  def delete_response(id) do
    %{"success" => true, "data" => %{"id" => id}}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-#{status}"}
  end
end
