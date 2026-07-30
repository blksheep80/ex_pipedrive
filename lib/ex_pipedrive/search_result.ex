defmodule ExPipedrive.SearchResult do
  @moduledoc """
  One hit from Pipedrive `GET /api/v2/itemSearch`.

  Pipedrive nests the entity under `items[].item` and tags it with `type`.
  This struct unwraps that shape and decodes known types into entity structs
  (`Deal`, `Person`, `Organization`, `Product`). Unknown types keep the raw
  item map.
  """

  use TypedStruct

  alias ExPipedrive.Deal
  alias ExPipedrive.Organization
  alias ExPipedrive.Person
  alias ExPipedrive.Product

  typedstruct do
    field :result_score, float()
    field :type, String.t()
    field :item, Deal.t() | Person.t() | Organization.t() | Product.t() | map()
    field :original_object, map()
  end

  @doc """
  Builds a search result from an `items[]` entry (`result_score` + `item`).
  """
  @spec new(map()) :: t()
  def new(%{"item" => item} = container) when is_map(item) do
    type = Map.get(item, "type")

    %__MODULE__{
      result_score: Map.get(container, "result_score"),
      type: type,
      item: decode_item(type, item),
      original_object: container
    }
  end

  def new(%{item: item} = container) when is_map(item) do
    container
    |> Map.new(fn {k, v} -> {to_string(k), v} end)
    |> new()
  end

  defp decode_item("deal", item), do: Deal.new(item)
  defp decode_item("person", item), do: Person.new_from_search(item)
  defp decode_item("organization", item), do: Organization.new(item)
  defp decode_item("product", item), do: Product.new(ensure_product_name(item))
  defp decode_item(_type, item), do: item

  # Search product payloads always include name in practice; Structable requires it.
  defp ensure_product_name(%{"name" => _} = item), do: item
  defp ensure_product_name(item), do: Map.put(item, "name", Map.get(item, "code") || "")
end
