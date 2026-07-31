defmodule ExPipedrive.Fixtures.V2ProductVariations do
  @moduledoc false

  def variation(id \\ 1, product_id \\ 1) do
    %{
      "id" => id,
      "name" => "Variation #{id}",
      "product_id" => product_id,
      "prices" => [
        %{
          "product_variation_id" => id,
          "price" => 10,
          "currency" => "EUR",
          "cost" => 20
        }
      ]
    }
  end

  def list_response(product_id, cursor \\ nil) do
    {data, next_cursor} =
      case cursor do
        nil -> {[variation(1, product_id), variation(2, product_id)], "variations-page-2"}
        "variations-page-2" -> {[variation(3, product_id)], nil}
        _ -> {[], nil}
      end

    %{
      "success" => true,
      "data" => data,
      "additional_data" => %{"next_cursor" => next_cursor}
    }
  end

  def create_response(product_id, attrs) when is_map(attrs) do
    base = variation(99, product_id)

    data = Map.merge(base, Map.take(attrs, ["name", "prices"]))

    %{"success" => true, "data" => data}
  end

  def update_response(product_id, variation_id, attrs) when is_map(attrs) do
    data = Map.merge(variation(variation_id, product_id), Map.take(attrs, ["name", "prices"]))
    %{"success" => true, "data" => data}
  end

  def delete_response(variation_id) do
    %{"success" => true, "data" => %{"id" => variation_id}}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-#{status}"}
  end
end
