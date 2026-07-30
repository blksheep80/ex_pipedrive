defmodule ExPipedrive.Deals.ListDealsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    Deal,
    Deals,
    PagedResult
  }

  describe "list_deals" do
    test "it forms a correct request and returns the correct data structure results for matching deals",
         %{client: client} do
      assert {:ok,
              %PagedResult{
                data: [%Deal{id: 1, title: "Mecklem, LLC deal"} | _]
              }} = Deals.list_deals(client)
    end
  end
end
