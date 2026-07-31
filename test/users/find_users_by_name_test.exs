defmodule ExPipedrive.Users.FindUsersByNameTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.User
  alias ExPipedrive.Users

  describe "find_users_by_name" do
    test "it decodes string-keyed JSON bodies into User structs", %{client: client} do
      assert {:ok, users} = Users.find_users_by_name(client, "Test")

      assert [
               %User{id: 123, name: "Test User", email: "test@example.com"},
               %User{id: 124, name: "Test Other User", email: "test.other@example.com"}
             ] = users
    end

    test "it forwards search_by_email? as an integer flag", %{client: client} do
      assert {:ok, [%User{id: 123, name: "Test User"}]} =
               Users.find_users_by_name(client, "Test", search_by_email?: true)
    end

    test "it returns an empty list when no users match", %{client: client} do
      assert {:ok, []} = Users.find_users_by_name(client, "Nobody")
    end

    test "it delegates from ExPipedrive", %{client: client} do
      assert {:ok, [%User{} | _]} = ExPipedrive.find_users_by_name(client, "Test")
    end
  end
end
