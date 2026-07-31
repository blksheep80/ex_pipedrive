defmodule ExPipedrive.RoleAssignment do
  @moduledoc """
  A user assignment on a Pipedrive role.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :user_id, pos_integer()
    field :role_id, pos_integer()
    field :parent_role_id, pos_integer()
    field :name, String.t()
    field :active_flag, boolean(), default: true
    field :type, String.t()
    field :original_object, map()
  end

  def handle_transform(map, original) do
    Map.put(map, :original_object, original)
  end
end
