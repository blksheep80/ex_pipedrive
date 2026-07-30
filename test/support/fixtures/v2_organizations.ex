defmodule ExPipedrive.Fixtures.V2Organizations do
  @moduledoc false

  @custom_fields %{
    "53c2f18db6a1655d6af8bba77d9679565f975fd8" => "Enterprise"
  }

  def organization(id \\ 1) do
    %{
      "id" => id,
      "name" => "Mecklem, LLC",
      "owner_id" => 15_783_886,
      "add_time" => "2022-07-09T15:16:26Z",
      "update_time" => "2023-02-22T22:05:25Z",
      "is_deleted" => false,
      "visible_to" => 3,
      "label_ids" => [],
      "address" => %{
        "value" => "123 Main St, Cincinnati, OH 45202",
        "country" => "US",
        "admin_area_level_1" => "OH",
        "locality" => "Cincinnati",
        "postal_code" => "45202",
        "route" => "Main St",
        "street_number" => "123"
      },
      "custom_fields" => @custom_fields
    }
  end

  def get_response(id \\ 1) do
    %{"success" => true, "data" => organization(id)}
  end

  def list_response(cursor \\ nil) do
    {data, next_cursor} =
      case cursor do
        nil -> {[organization(1), organization(2)], "orgs-page-2"}
        "orgs-page-2" -> {[organization(3)], nil}
        _ -> {[], nil}
      end

    %{
      "success" => true,
      "data" => data,
      "additional_data" => %{"next_cursor" => next_cursor}
    }
  end

  def create_response(attrs) when is_map(attrs) do
    base = organization(99)

    data =
      base
      |> Map.merge(
        Map.take(attrs, ["name", "owner_id", "visible_to", "label_ids", "custom_fields"])
      )
      |> maybe_merge_address(attrs)

    %{"success" => true, "data" => data}
  end

  def update_response(id, attrs) when is_map(attrs) do
    data =
      id
      |> organization()
      |> Map.merge(Map.drop(attrs, ["address"]))
      |> maybe_merge_address(attrs)

    %{"success" => true, "data" => data}
  end

  def delete_response(id) do
    %{"success" => true, "data" => %{"id" => id}}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-#{status}"}
  end

  defp maybe_merge_address(data, %{"address" => address}) when is_binary(address) do
    Map.put(data, "address", %{"value" => address})
  end

  defp maybe_merge_address(data, %{"address" => address}) when is_map(address) do
    Map.put(data, "address", address)
  end

  defp maybe_merge_address(data, _), do: data
end
