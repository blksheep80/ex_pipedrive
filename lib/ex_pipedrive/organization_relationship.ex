defmodule ExPipedrive.OrganizationRelationship do
  @moduledoc """
  A relationship between two organizations, from `/api/v1/organizationRelationships`.

  `type` is `"parent"` (hierarchical) or `"related"` (lateral). For `"parent"`,
  `rel_owner_org_id` is the parent and `rel_linked_org_id` is the daughter.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :org_id, pos_integer()
    field :type, String.t()
    field :rel_owner_org_id, pos_integer()
    field :rel_linked_org_id, pos_integer()
    field :original_object, map()
  end

  def handle_transform(map, original_map) do
    map
    |> Map.update(:org_id, nil, &normalize_id/1)
    |> Map.update(:rel_owner_org_id, nil, &normalize_id/1)
    |> Map.update(:rel_linked_org_id, nil, &normalize_id/1)
    |> Map.put(:original_object, original_map)
  end
end
