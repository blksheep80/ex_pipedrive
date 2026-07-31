defmodule ExPipedrive.Currency do
  @moduledoc """
  A supported currency in a Pipedrive account.

  For non-custom currencies, `:code` is the ISO-4217 code. Custom currencies
  (configured in the Pipedrive UI) set `:is_custom_flag` to `true`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :code, String.t()
    field :name, String.t()
    field :decimal_points, non_neg_integer()
    field :symbol, String.t()
    field :active_flag, boolean(), default: true
    field :is_custom_flag, boolean(), default: false
    field :original_object, map()
  end

  def handle_transform(map, original) do
    Map.put(map, :original_object, original)
  end
end
