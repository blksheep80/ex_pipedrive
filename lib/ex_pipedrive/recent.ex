defmodule ExPipedrive.Recent do
  @moduledoc """
  A recent-change entry from `GET /api/v1/recents`.

  `:item` is the entity type (`"deal"`, `"person"`, …). `:data` is the raw
  item payload for that type (left as a map — shape varies by `:item`).
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :item, String.t()
    field :id, term()
    field :data, map()
    field :original_object, map()
  end

  def handle_transform(map, original) do
    Map.put(map, :original_object, original)
  end
end
