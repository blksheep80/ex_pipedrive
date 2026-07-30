defmodule ExPipedrive.Products.StreamProductsTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Page
  alias ExPipedrive.Product
  alias ExPipedrive.Products

  describe "list_products_page/2" do
    test "returns a Page wrapper with next_cursor", %{client: client} do
      assert {:ok, %Page{data: products, next_cursor: "products-page-2"}} =
               Products.list_products_page(client, limit: 100)

      assert Enum.map(products, & &1.id) == [1, 2]
      assert Enum.all?(products, &match?(%Product{}, &1))
    end

    test "returns the final page when cursor is exhausted", %{client: client} do
      assert {:ok, %Page{data: products, next_cursor: nil}} =
               Products.list_products_page(client, cursor: "products-page-2")

      assert Enum.map(products, & &1.id) == [3]
      assert Page.done?(%Page{data: products, next_cursor: nil})
    end
  end

  describe "stream_products/2" do
    test "auto-follows cursors until exhausted", %{client: client} do
      products = client |> Products.stream_products(limit: 100) |> Enum.to_list()

      assert Enum.map(products, & &1.id) == [1, 2, 3]
      assert Enum.all?(products, &match?(%Product{}, &1))
    end
  end
end
