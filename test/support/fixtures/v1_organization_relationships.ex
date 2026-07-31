defmodule ExPipedrive.Fixtures.V1OrganizationRelationships do
  @moduledoc false

  def relationship(id, org_id, type \\ "parent", owner_id \\ 1, linked_id \\ 2) do
    %{
      "id" => id,
      "org_id" => org_id,
      "type" => type,
      "rel_owner_org_id" => owner_id,
      "rel_linked_org_id" => linked_id
    }
  end

  def list_response(org_id) do
    %{"success" => true, "data" => [relationship(1, org_id)]}
  end

  def get_response(id) do
    %{"success" => true, "data" => relationship(id, 1)}
  end

  def create_response(attrs) do
    %{
      "success" => true,
      "data" =>
        relationship(
          10,
          Map.get(attrs, "org_id", 1),
          Map.get(attrs, "type", "parent"),
          Map.get(attrs, "rel_owner_org_id", 1),
          Map.get(attrs, "rel_linked_org_id", 2)
        )
    }
  end

  def update_response(id, attrs) do
    %{
      "success" => true,
      "data" =>
        relationship(
          id,
          Map.get(attrs, "org_id", 1),
          Map.get(attrs, "type", "related"),
          Map.get(attrs, "rel_owner_org_id", 1),
          Map.get(attrs, "rel_linked_org_id", 2)
        )
    }
  end

  def delete_response(id) do
    %{"success" => true, "data" => %{"id" => id}}
  end
end
