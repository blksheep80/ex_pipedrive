defmodule ExPipedrive.Deals.GetDealTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias ExPipedrive.{
    Deal,
    Deals,
    FakePipedriveServer
  }

  setup do
    start_supervised(
      {Plug.Cowboy, scheme: :http, plug: FakePipedriveServer, options: [port: 4006]}
    )

    client = ExPipedrive.client("api_token", "http://localhost:4006/")
    {:ok, client: client}
  end

  describe "get_deal" do
    test "it forms a correct request and returns the deal when it exists", %{client: client} do
      assert {:ok, %Deal{id: 1}} = Deals.get_deal(client, 1)
    end

    # test "with invalid request it returns the error", %{
    #   client: client
    # } do
    #   assert {:error, _error} = HubSpotClient.list_deals(client, limit: -1)
    # end
  end
end
