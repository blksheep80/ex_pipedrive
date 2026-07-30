defmodule LineDrive.Pipeline do
  @moduledoc """
  This module and enclosed struct represent a pipeline in pipedrive.
  """

  use TypedStruct
  use LineDrive.Structable

  typedstruct enforce: true do
    field :active, boolean()
    field :add_time, NaiveDateTime.t()
    field :deal_probability, float()
    field :id, pos_integer()
    field :name, String.t()
    field :order_nr, pos_integer()
    field :selected, boolean()
    field :update_time, NaiveDateTime.t()
    field :url_title, String.t()
  end

  def handle_transform(map, _original_map) do
    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
  end
end
