defmodule ExPipedrive.Fixtures.V2Products do
  @moduledoc false

  @custom_fields %{
    "53c2f18db6a1655d6af8bba77d9679565f975fd8" => "Catalog SKU"
  }

  def product(id \\ 1) do
    %{
      "id" => id,
      "name" => "Widget",
      "code" => "WDG-#{id}",
      "description" => "A fine widget",
      "unit" => "pcs",
      "tax" => 20,
      "category" => "262",
      "owner_id" => 15_783_886,
      "visible_to" => 7,
      "is_deleted" => false,
      "is_linkable" => true,
      "billing_frequency" => "one-time",
      "billing_frequency_cycles" => nil,
      "add_time" => "2024-01-01T00:00:00Z",
      "update_time" => "2024-01-01T00:00:00Z",
      "prices" => [
        %{
          "product_id" => id,
          "price" => 54,
          "currency" => "EUR",
          "cost" => 0,
          "direct_cost" => 0
        }
      ],
      "custom_fields" => @custom_fields
    }
  end

  def get_response(id \\ 1) do
    %{"success" => true, "data" => product(id)}
  end

  def list_response(cursor \\ nil) do
    {data, next_cursor} =
      case cursor do
        nil -> {[product(1), product(2)], "products-page-2"}
        "products-page-2" -> {[product(3)], nil}
        _ -> {[], nil}
      end

    %{
      "success" => true,
      "data" => data,
      "additional_data" => %{"next_cursor" => next_cursor}
    }
  end

  def create_response(attrs) when is_map(attrs) do
    base = product(99)

    data =
      Map.merge(
        base,
        Map.take(attrs, [
          "name",
          "code",
          "description",
          "unit",
          "tax",
          "category",
          "owner_id",
          "visible_to",
          "is_linkable",
          "prices",
          "custom_fields",
          "billing_frequency",
          "billing_frequency_cycles"
        ])
      )

    %{"success" => true, "data" => data}
  end

  def update_response(id, attrs) when is_map(attrs) do
    %{"success" => true, "data" => Map.merge(product(id), attrs)}
  end

  def delete_response(id) do
    %{"success" => true, "data" => %{"id" => id}}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-#{status}"}
  end
end
