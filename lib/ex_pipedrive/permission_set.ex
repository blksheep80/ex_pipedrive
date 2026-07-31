defmodule ExPipedrive.PermissionSet do
  @moduledoc """
  A Pipedrive permission set (`/api/v1/permissionSets`).

  Ids are UUID strings. `:contents` is the list of permission keys present on
  a single-set fetch (may be empty for list responses).
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, String.t()
    field :name, String.t()
    field :description, String.t()
    field :app, String.t()
    field :type, String.t()
    field :assignment_count, non_neg_integer()
    field :contents, list(String.t()), default: []
    field :original_object, map()
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:contents, [], &(&1 || []))
    |> Map.put(:original_object, original)
  end
end
