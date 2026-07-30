defmodule ExPipedrive.Organizations.SearchOrganizationsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    Organization,
    Organizations
  }

  describe "search_organizations" do
    test "it forms a correct request and returns the correct data structure results for matching organizations",
         %{client: client} do
      assert {:ok, [%Organization{id: 2, name: "Great Amazing Organization"}]} =
               Organizations.search_organizations(client, "great")
    end

    # test "with invalid request it returns the error", %{
    #   client: client
    # } do
    #   assert {:error, _error} = HubSpotClient.list_organizations(client, limit: -1)
    # end
  end
end
