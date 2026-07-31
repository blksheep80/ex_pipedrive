defmodule ExPipedrive.Products.ProductVariationsV2Test do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.ProductVariation
  alias ExPipedrive.ProductVariations

  describe "list_page/3" do
    test "returns typed ProductVariations for a product", %{client: client} do
      assert {:ok, %ExPipedrive.Page{data: variations, next_cursor: "variations-page-2"}} =
               ProductVariations.list_page(client, 1)

      assert [
               %ProductVariation{id: 1, name: "Variation 1", product_id: 1},
               %ProductVariation{id: 2, name: "Variation 2", product_id: 1}
             ] = variations

      assert [%{"currency" => "EUR", "price" => 10}] = hd(variations).prices
    end

    test "maps a missing product to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = ProductVariations.list_page(client, 404)
    end
  end

  describe "stream/3" do
    test "streams all variation pages for a product", %{client: client} do
      variations = client |> ProductVariations.stream(1, limit: 500) |> Enum.to_list()
      assert Enum.map(variations, & &1.id) == [1, 2, 3]
      assert Enum.all?(variations, &(&1.product_id == 1))
    end
  end

  describe "get/3" do
    test "finds a variation by id via the stream", %{client: client} do
      assert {:ok, %ProductVariation{id: 2, name: "Variation 2"}} =
               ProductVariations.get(client, 1, 2)
    end

    test "returns a structured not_found error when the id is absent", %{client: client} do
      assert {:error, %Error{kind: :not_found, status: 404}} =
               ProductVariations.get(client, 1, 999)
    end
  end

  describe "create/3" do
    test "creates a variation from a map and returns a ProductVariation", %{client: client} do
      assert {:ok,
              %ProductVariation{
                id: 99,
                name: "Large",
                product_id: 1
              } = variation} =
               ProductVariations.create(client, 1, %{
                 name: "Large",
                 prices: [%{currency: "USD", price: 24.99}]
               })

      assert [%{"currency" => "USD", "price" => 24.99}] = variation.prices
    end

    test "creates a variation from a ProductVariation struct write attrs", %{client: client} do
      assert {:ok, %ProductVariation{id: 99, name: "From struct"}} =
               ProductVariations.create(client, 1, %ProductVariation{name: "From struct"})
    end
  end

  describe "update/4" do
    test "patches a variation and returns the updated ProductVariation", %{client: client} do
      assert {:ok, %ProductVariation{id: 2, name: "Updated Variation", product_id: 1}} =
               ProductVariations.update(client, 1, 2, %{name: "Updated Variation"})
    end

    test "maps a missing variation to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} =
               ProductVariations.update(client, 1, 404, %{name: "x"})
    end
  end

  describe "delete/3" do
    test "deletes a variation", %{client: client} do
      assert {:ok, %{"success" => true, "data" => %{"id" => 2}}} =
               ProductVariations.delete(client, 1, 2)
    end

    test "maps a missing variation delete to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = ProductVariations.delete(client, 1, 404)
    end
  end
end
