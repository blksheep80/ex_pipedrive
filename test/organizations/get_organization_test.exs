defmodule ExPipedrive.Organizations.GetOrganizationTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    FakePipedriveServer,
    Organization,
    Organizations
  }

  setup do
    start_supervised(
      {Plug.Cowboy, scheme: :http, plug: FakePipedriveServer, options: [port: 4006]}
    )

    client = ExPipedrive.client("api_token", "http://localhost:4006/")
    {:ok, client: client}
  end

  describe "get_organization" do
    test "it forms a correct request and returns the organization when it exists", %{
      client: client
    } do
      assert {:ok, %Organization{id: 1}} = Organizations.get_organization(client, 1)
    end

    # test "with invalid request it returns the error", %{
    #   client: client
    # } do
    #   assert {:error, _error} = HubSpotClient.list_organizations(client, limit: -1)
    # end
  end
end
