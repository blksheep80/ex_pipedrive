defmodule ExPipedrive.Organizations.OrganizationsV2Test do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.Organization
  alias ExPipedrive.Organizations

  describe "get/2" do
    test "returns a typed Organization from v2", %{client: client} do
      assert {:ok,
              %Organization{
                id: 1,
                name: "Mecklem, LLC",
                address: address,
                custom_fields: fields
              }} = Organizations.get(client, 1)

      assert address == "123 Main St, Cincinnati, OH 45202"
      assert is_map(fields)
      assert map_size(fields) > 0
    end

    test "maps missing organizations to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Organizations.get(client, 404)
    end
  end

  describe "create/2" do
    test "creates from a map and returns an Organization", %{client: client} do
      assert {:ok, %Organization{id: 99, name: "New Org", address: address}} =
               Organizations.create(client, %{
                 name: "New Org",
                 address: "1 Infinite Loop"
               })

      assert address == "1 Infinite Loop"
    end

    test "creates from an Organization struct write attrs", %{client: client} do
      assert {:ok, %Organization{id: 99, name: "From struct"}} =
               Organizations.create(client, %Organization{name: "From struct"})
    end
  end

  describe "update/3" do
    test "patches an organization", %{client: client} do
      assert {:ok, %Organization{id: 1, name: "Updated Org"}} =
               Organizations.update(client, 1, %{name: "Updated Org"})
    end
  end

  describe "delete/2" do
    test "deletes an organization", %{client: client} do
      assert {:ok, %{"success" => true, "data" => %{"id" => 1}}} = Organizations.delete(client, 1)
    end

    test "maps missing deletes to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Organizations.delete(client, 404)
    end
  end

  describe "stream/2 alias" do
    test "streams organizations via the MVP-friendly name", %{client: client} do
      orgs = client |> Organizations.stream(limit: 500) |> Enum.to_list()
      assert Enum.map(orgs, & &1.id) == [1, 2, 3]
    end
  end
end
