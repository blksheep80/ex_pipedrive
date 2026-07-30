defmodule ExPipedrive.Deals.StreamDealsTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Deal
  alias ExPipedrive.Deals
  alias ExPipedrive.Page

  describe "list_deals_page/2" do
    test "returns a Page wrapper with next_cursor", %{client: client} do
      assert {:ok, %Page{data: deals, next_cursor: "cursor-page-2"}} =
               Deals.list_deals_page(client, limit: 100)

      assert Enum.map(deals, & &1.id) == [1, 2]
      assert Enum.all?(deals, &match?(%Deal{}, &1))
    end

    test "returns the final page when cursor is exhausted", %{client: client} do
      assert {:ok, %Page{data: deals, next_cursor: nil}} =
               Deals.list_deals_page(client, cursor: "cursor-page-2")

      assert Enum.map(deals, & &1.id) == [3]
      assert Page.done?(%Page{data: deals, next_cursor: nil})
    end
  end

  describe "stream_deals/2" do
    test "auto-follows cursors until exhausted (MVP open-deals sync)", %{client: client} do
      deals = client |> Deals.stream_deals(limit: 100) |> Enum.to_list()

      assert Enum.map(deals, & &1.id) == [1, 2, 3]
      assert Enum.all?(deals, &match?(%Deal{}, &1))
    end
  end
end
