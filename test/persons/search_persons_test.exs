defmodule ExPipedrive.Contacts.SearchPersonsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.Person
  alias ExPipedrive.Persons

  describe "search_persons" do
    test "it forms a correct request and returns the correct data structure results for matching persons",
         %{client: client} do
      assert {:ok,
              [
                %Person{
                  id: 1,
                  name: "Tim Mecklem",
                  organization: %{name: "Mecklem, LLC"}
                }
              ]} = Persons.search_persons(client, "tim")
    end

    # test "with invalid request it returns the error", %{
    #   client: client
    # } do
    #   assert {:error, _error} = HubSpotClient.list_deals(client, limit: -1)
    # end
  end
end
