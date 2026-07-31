defmodule ExPipedrive.Goal do
  @moduledoc """
  This module and enclosed structs represent a sales goal in Pipedrive.

  Unlike most Pipedrive entities, `id` is a Pipedrive-generated hex string
  (e.g. `"5665cef556ddff22606fc8f6c0004807"`), not an integer.

  `:type`, `:assignee`, `:expected_outcome`, and `:duration` are decoded as
  plain maps (not typed structs) — see `ExPipedrive.Goals` for their nested
  JSON shape.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, String.t()
    field :owner_id, pos_integer()
    field :title, String.t()
    field :type, map()
    field :assignee, map()
    field :interval, String.t()
    field :duration, map()
    field :expected_outcome, map()
    field :is_active, boolean()
    field :report_ids, list(String.t()), default: []
    field :original_object, map()
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:report_ids, [], &(&1 || []))
    |> Map.put(:original_object, original)
  end
end
