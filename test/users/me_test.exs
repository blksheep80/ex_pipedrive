defmodule ExPipedrive.Users.MeTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.User
  alias ExPipedrive.Users

  describe "me" do
    test "it forms a correct request and returns the current user", %{client: client} do
      assert {:ok,
              %User{
                id: 123,
                name: "Test User",
                email: "test@example.com",
                active_flag: true
              }} = Users.me(client)
    end
  end
end
