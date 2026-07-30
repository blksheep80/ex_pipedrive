defmodule ExPipedrive.Product do
  @moduledoc """
  Product entity decoded from Pipedrive API v2 responses.

  Prices are kept as maps (`currency`, `price`, `cost`, `direct_cost`, …).
  Product variations live on a separate API and are not embedded here.
  The raw payload remains on `original_object`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :name, String.t(), enforce: true
    field :code, String.t()
    field :description, String.t()
    field :unit, String.t()
    field :tax, number()
    field :category, String.t() | number()
    field :owner_id, pos_integer()
    field :visible_to, String.t() | non_neg_integer()
    field :is_deleted, boolean()
    field :is_linkable, boolean()
    field :prices, list(), default: []
    field :billing_frequency, String.t()
    field :billing_frequency_cycles, integer()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :update_time, DateTime.t() | NaiveDateTime.t()
    field :custom_fields, map(), default: %{}
    field :original_object, map()
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(%{id: nil} = product, opts) do
      Jason.Encode.value(
        Map.take(Map.from_struct(product), [
          :name,
          :code,
          :description,
          :unit,
          :tax,
          :category,
          :owner_id,
          :visible_to,
          :is_linkable,
          :prices,
          :billing_frequency,
          :billing_frequency_cycles,
          :custom_fields
        ]),
        opts
      )
    end

    def encode(product, opts), do: Jason.encode(product, opts)
  end

  def handle_transform(map, original_map, opts \\ []) do
    _version = Keyword.get(opts, :version, :auto)

    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.update(:owner_id, nil, &normalize_id/1)
    |> Map.update(:visible_to, nil, &parse_integer/1)
    |> Map.update(:prices, [], &normalize_prices/1)
    |> Map.put(:custom_fields, extract_custom_fields(original_map))
    |> Map.put(:original_object, original_map)
  end

  defp normalize_prices(nil), do: []
  defp normalize_prices(prices) when is_list(prices), do: prices
  defp normalize_prices(_), do: []
end
