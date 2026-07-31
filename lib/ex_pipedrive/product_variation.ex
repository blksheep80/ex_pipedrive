defmodule ExPipedrive.ProductVariation do
  @moduledoc """
  Product variation entity decoded from Pipedrive API v2 responses.

  Variations live on the separate `/api/v2/products/:id/variations` API (see
  `ExPipedrive.ProductVariations`), not embedded in `ExPipedrive.Product`.
  Prices are kept as maps (`currency`, `price`, `cost`, `direct_cost`,
  `notes`). The raw payload remains on `original_object`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :name, String.t(), enforce: true
    field :product_id, pos_integer()
    field :prices, list(), default: []
    field :original_object, map()
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(%{id: nil} = variation, opts) do
      Jason.Encode.value(
        Map.take(Map.from_struct(variation), [:name, :prices]),
        opts
      )
    end

    def encode(variation, opts), do: Jason.encode(variation, opts)
  end

  def handle_transform(map, original_map, opts \\ []) do
    _version = Keyword.get(opts, :version, :auto)

    map
    |> Map.update(:product_id, nil, &normalize_id/1)
    |> Map.update(:prices, [], &normalize_prices/1)
    |> Map.put(:original_object, original_map)
  end

  defp normalize_prices(nil), do: []
  defp normalize_prices(prices) when is_list(prices), do: prices
  defp normalize_prices(_), do: []
end
