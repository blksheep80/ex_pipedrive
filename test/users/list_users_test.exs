defmodule ExPipedrive.Users.ListUsersTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    PagedResult,
    User,
    Users
  }

  describe "list" do
    test "it forms a correct request and returns the correct data structure results for all users",
         %{client: client} do
      assert {:ok,
              %PagedResult{
                success: true,
                data: users,
                additional_data: %{pagination: pagination}
              }} = Users.list(client)

      assert is_list(users)
      assert [%User{id: 123, name: "Test User"}, %User{id: 124}] = users
      assert %{start: _, limit: _, more_items_in_collection: _} = pagination
    end

    test "it accepts pagination parameters", %{client: client} do
      assert {:ok,
              %PagedResult{
                success: true,
                additional_data: %{pagination: %{start: 10, limit: 5}}
              }} = Users.list(client, start: 10, limit: 5)
    end
  end
end
