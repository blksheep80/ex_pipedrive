defmodule ExPipedrive.Role do
  @moduledoc """
  A Pipedrive visibility-group role (`/api/v1/roles`).
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :parent_role_id, pos_integer()
    field :name, String.t()
    field :active_flag, boolean(), default: true
    field :assignment_count, String.t()
    field :sub_role_count, String.t()
    field :level, integer()
    field :original_object, map()
  end

  def handle_transform(map, original) do
    Map.put(map, :original_object, original)
  end
end
