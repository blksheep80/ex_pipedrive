defmodule ExPipedrive.Products.ProductsV2Test do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.Product
  alias ExPipedrive.Products

  describe "get/2" do
    test "returns a typed Product from v2", %{client: client} do
      assert {:ok,
              %Product{
                id: 1,
                name: "Widget",
                code: "WDG-1",
                owner_id: 15_783_886,
                is_linkable: true,
                tax: 20
              } = product} = Products.get(client, 1)

      assert product.custom_fields["53c2f18db6a1655d6af8bba77d9679565f975fd8"] == "Catalog SKU"
      assert [%{"currency" => "EUR", "price" => 54}] = product.prices
      assert %DateTime{} = product.add_time
    end

    test "maps missing products to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Products.get(client, 404)
    end
  end

  describe "create/2" do
    test "creates from a map and returns a Product", %{client: client} do
      assert {:ok,
              %Product{
                id: 99,
                name: "Gadget",
                code: "GDG-1",
                unit: "box",
                tax: 10,
                is_linkable: true
              }} =
               Products.create(client, %{
                 name: "Gadget",
                 code: "GDG-1",
                 unit: "box",
                 tax: 10,
                 is_linkable: true,
                 prices: [%{currency: "USD", price: 19.99}]
               })
    end

    test "creates from a Product struct write attrs", %{client: client} do
      assert {:ok, %Product{id: 99, name: "From struct", code: "FS-1"}} =
               Products.create(client, %Product{name: "From struct", code: "FS-1"})
    end
  end

  describe "update/3" do
    test "patches a product and returns the updated Product", %{client: client} do
      assert {:ok, %Product{id: 1, name: "Updated Widget", tax: 15}} =
               Products.update(client, 1, %{name: "Updated Widget", tax: 15})
    end
  end

  describe "delete/2" do
    test "deletes a product", %{client: client} do
      assert {:ok, %{"success" => true, "data" => %{"id" => 1}}} = Products.delete(client, 1)
    end

    test "maps missing deletes to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Products.delete(client, 404)
    end
  end

  describe "stream/2 alias" do
    test "streams products via the friendly name", %{client: client} do
      products = client |> Products.stream(limit: 500) |> Enum.to_list()
      assert Enum.map(products, & &1.id) == [1, 2, 3]
    end
  end
end
