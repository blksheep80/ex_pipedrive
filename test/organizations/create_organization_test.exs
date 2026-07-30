defmodule ExPipedrive.Organizations.CreateOrganizationTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    Organization,
    Organizations
  }

  describe "create_organization" do
    test "it forms a correct request and returns the correct data structure results for new organization",
         %{client: client} do
      assert {:ok, %Organization{id: 1, name: "New Org"}} =
               Organizations.create_organization(client, %Organization{name: "New Org"})
    end

    # test "with invalid request it returns the error", %{
    #   client: client
    # } do
    #   assert {:error, _error} = HubSpotClient.list_deals(client, limit: -1)
    # end
  end
end
