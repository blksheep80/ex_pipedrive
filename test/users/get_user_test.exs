defmodule ExPipedrive.Users.GetUserTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.User
  alias ExPipedrive.Users

  describe "get" do
    test "it forms a correct request and returns the user when it exists", %{client: client} do
      assert {:ok,
              %User{
                id: 123,
                name: "Test User",
                email: "test@example.com",
                active_flag: true
              }} = Users.get(client, 123)
    end

    test "it returns an error when the user does not exist", %{client: client} do
      assert {:error, %ExPipedrive.Error{}} = Users.get(client, 404)
    end
  end
end
