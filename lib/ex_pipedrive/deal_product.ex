defmodule ExPipedrive.DealProduct do
  @moduledoc """
  A product attachment on a deal (`/api/v2/deals/:id/products`).

  `:id` is the **deal-product** (attachment) id, not the catalog `product_id`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :sum, number()
    field :tax, number()
    field :deal_id, pos_integer()
    field :name, String.t()
    field :product_id, pos_integer()
    field :product_variation_id, pos_integer()
    field :order_nr, integer()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :update_time, DateTime.t() | NaiveDateTime.t()
    field :comments, String.t()
    field :currency, String.t()
    field :discount, number()
    field :discount_type, String.t()
    field :quantity, number()
    field :item_price, number()
    field :tax_method, String.t()
    field :is_enabled, boolean(), default: true
    field :billing_frequency, String.t()
    field :billing_frequency_cycles, integer()
    field :billing_start_date, Date.t()
    field :original_object, map()
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:deal_id, nil, &normalize_id/1)
    |> Map.update(:product_id, nil, &normalize_id/1)
    |> Map.update(:product_variation_id, nil, &normalize_id/1)
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.update(:billing_start_date, nil, &parse_date/1)
    |> Map.put(:original_object, original)
  end
end
