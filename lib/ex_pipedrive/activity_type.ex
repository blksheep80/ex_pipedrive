defmodule LineDrive.ActivityType do
  @moduledoc """
  This module and enclosed struct represent a activity type in pipedrive.
  """

  use TypedStruct
  use LineDrive.Structable

  @type key_string :: binary()

  typedstruct enforce: true do
    field :active_flag, boolean()
    field :add_time, NaiveDateTime.t()
    field :id, pos_integer()
    field :is_custom_flag, boolean()
    field :key_string, key_string()
    field :name, String.t()
    field :update_time, NaiveDateTime.t()
  end

  def handle_transform(map, _) do
    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
  end
end
