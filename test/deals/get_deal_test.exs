defmodule ExPipedrive.Deals.GetDealTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Deal
  alias ExPipedrive.Deals

  describe "get_deal" do
    test "it forms a correct request and returns the deal when it exists", %{client: client} do
      assert {:ok, %Deal{id: 1}} = Deals.get_deal(client, 1)
    end
  end
end
