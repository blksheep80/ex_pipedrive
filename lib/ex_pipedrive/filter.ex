defmodule ExPipedrive.Filter do
  @moduledoc """
  This module and enclosed structs represent a filter in pipedrive.

  `conditions` is decoded as a plain map — see `ExPipedrive.Filters` for the
  nested AND/OR condition-group shape Pipedrive expects.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :name, String.t()
    field :active_flag, boolean()
    field :type, String.t()
    field :temporary_flag, boolean()
    field :user_id, pos_integer()
    field :add_time, DateTime.t()
    field :update_time, DateTime.t()
    field :visible_to, String.t()
    field :custom_view_id, pos_integer()
    field :conditions, map()
    field :original_object, map()
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.put(:original_object, original)
  end
end
