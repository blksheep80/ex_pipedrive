defmodule ExPipedrive.AdminMetaApisTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Currencies
  alias ExPipedrive.Currency
  alias ExPipedrive.Error
  alias ExPipedrive.PagedResult
  alias ExPipedrive.PermissionSet
  alias ExPipedrive.PermissionSets
  alias ExPipedrive.Recent
  alias ExPipedrive.Recents
  alias ExPipedrive.Role
  alias ExPipedrive.RoleAssignment
  alias ExPipedrive.Roles
  alias ExPipedrive.Team
  alias ExPipedrive.Teams

  @permission_set_id "f07d229d-088a-4144-a40f-1fe64295d180"

  describe "Currencies" do
    test "list/2 returns supported currencies", %{client: client} do
      assert {:ok,
              [
                %Currency{id: 1, code: "EUR", name: "Euro", symbol: "€", is_custom_flag: false},
                %Currency{id: 2, code: "USD", name: "US Dollar"}
              ]} = Currencies.list(client)
    end

    test "list/2 filters by term", %{client: client} do
      assert {:ok, [%Currency{code: "EUR"}]} = Currencies.list(client, term: "eur")
    end

    test "get/2 and get_by_code/2 look up client-side", %{client: client} do
      assert {:ok, %Currency{code: "USD"}} = Currencies.get(client, 2)
      assert {:ok, %Currency{id: 1}} = Currencies.get_by_code(client, "eur")
      assert {:error, %Error{kind: :not_found}} = Currencies.get(client, 999)
    end
  end

  describe "Recents" do
    test "list/2 requires since_timestamp and returns Recent entries", %{client: client} do
      assert {:ok, %PagedResult{data: [%Recent{item: "deal", id: 10}, %Recent{item: "person"}]}} =
               Recents.list(client, since_timestamp: "2024-01-01 00:00:00")
    end

    test "list/2 filters by items", %{client: client} do
      assert {:ok, %PagedResult{data: [%Recent{item: "deal"}]}} =
               Recents.list(client,
                 since_timestamp: "2024-01-01 00:00:00",
                 items: ["deal"]
               )
    end
  end

  describe "Roles" do
    test "list/2 and get/2", %{client: client} do
      assert {:ok, [%Role{id: 1}, %Role{id: 2, name: "Admins"}]} = Roles.list(client)
      assert {:ok, %Role{id: 2, name: "Admins", parent_role_id: 1}} = Roles.get(client, 2)
      assert {:error, %Error{kind: :not_found}} = Roles.get(client, 404)
    end

    test "list_assignments/3, list_pipelines/2, list_settings/2", %{client: client} do
      assert {:ok, %PagedResult{data: [%RoleAssignment{user_id: 1_234_567, role_id: 2}]}} =
               Roles.list_assignments(client, 2)

      assert {:ok, %{"1" => true, "2" => false}} = Roles.list_pipelines(client, 2)
      assert {:ok, %{"deal_default_visibility" => 3}} = Roles.list_settings(client, 2)
    end
  end

  describe "PermissionSets" do
    test "list/2, get/2, list_assignments/3", %{client: client} do
      assert {:ok, [%PermissionSet{id: @permission_set_id, app: "sales", type: "regular"}]} =
               PermissionSets.list(client, app: "sales")

      assert {:ok,
              %PermissionSet{
                id: @permission_set_id,
                contents: ["can_add_products", "can_see_other_users"]
              }} = PermissionSets.get(client, @permission_set_id)

      assert {:ok, %PagedResult{data: [%{"user_id" => 42}]}} =
               PermissionSets.list_assignments(client, @permission_set_id)

      assert {:error, %Error{kind: :not_found}} = PermissionSets.get(client, "404")
    end
  end

  describe "Teams (legacyTeams)" do
    test "list/2, get/2, list_users/2, list_for_user/2", %{client: client} do
      assert {:ok,
              [
                %Team{
                  id: 1,
                  name: "Closers",
                  manager_id: 4,
                  users: [2, 3, 4, 5],
                  active_flag: true,
                  deleted_flag: false
                }
              ]} = Teams.list(client)

      assert {:ok, %Team{id: 1, name: "Closers"}} = Teams.get(client, 1)
      assert {:ok, [2, 3, 4, 5]} = Teams.list_users(client, 1)
      assert {:ok, [%Team{id: 1}]} = Teams.list_for_user(client, 5)
      assert {:ok, []} = Teams.list_for_user(client, 99)
      assert {:error, %Error{kind: :not_found}} = Teams.get(client, 404)
    end
  end
end
