defmodule ExPipedrive.OrganizationRelationshipsTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.OrganizationRelationship
  alias ExPipedrive.OrganizationRelationships

  describe "list/2" do
    test "lists relationships for an organization", %{client: client} do
      assert {:ok, [%OrganizationRelationship{id: 1, org_id: 1, type: "parent"}]} =
               OrganizationRelationships.list(client, 1)
    end
  end

  describe "get/3" do
    test "fetches a relationship by id", %{client: client} do
      assert {:ok, %OrganizationRelationship{id: 1, type: "parent"}} =
               OrganizationRelationships.get(client, 1)
    end
  end

  describe "create/2" do
    test "creates a relationship", %{client: client} do
      assert {:ok,
              %OrganizationRelationship{
                id: 10,
                type: "parent",
                rel_owner_org_id: 1,
                rel_linked_org_id: 2
              }} =
               OrganizationRelationships.create(client, %{
                 type: "parent",
                 rel_owner_org_id: 1,
                 rel_linked_org_id: 2
               })
    end
  end

  describe "update/3" do
    test "updates a relationship", %{client: client} do
      assert {:ok, %OrganizationRelationship{id: 1, type: "related"}} =
               OrganizationRelationships.update(client, 1, %{type: "related"})
    end
  end

  describe "delete/2" do
    test "deletes a relationship", %{client: client} do
      assert {:ok, :ok} = OrganizationRelationships.delete(client, 1)
    end
  end
end
