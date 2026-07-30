defmodule ExPipedrive.Deals.SearchDealsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    Deal,
    Deals
  }

  describe "search_deals" do
    test "it forms a correct request and returns the correct data structure results for matching deals",
         %{client: client} do
      assert {:ok, [%Deal{id: 2, title: "Great Amazing Deal"}]} =
               Deals.search_deals(client, "great")
    end

    # test "with invalid request it returns the error", %{
    #   client: client
    # } do
    #   assert {:error, _error} = HubSpotClient.list_deals(client, limit: -1)
    # end
  end
end
