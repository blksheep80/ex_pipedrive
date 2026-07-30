defmodule ExPipedrive.Contacts.GetPersonTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    Person,
    Persons
  }

  describe "get_person" do
    test "it forms a correct request and returns the correct data structure results for matching persons",
         %{client: client} do
      assert {:ok, %Person{id: 1, name: "Tim Mecklem"}} = Persons.get_person(client, 1)
    end

    # test "with invalid request it returns the error", %{
    #   client: client
    # } do
    #   assert {:error, _error} = HubSpotClient.list_deals(client, limit: -1)
    # end
  end
end
