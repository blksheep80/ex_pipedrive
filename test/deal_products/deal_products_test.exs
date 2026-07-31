defmodule ExPipedrive.DealProductsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.DealProduct
  alias ExPipedrive.DealProducts
  alias ExPipedrive.Error
  alias ExPipedrive.Page

  describe "list_page/3 and stream/3" do
    test "lists products attached to a deal", %{client: client} do
      assert {:ok,
              %Page{
                data: [
                  %DealProduct{
                    id: 3,
                    deal_id: 1,
                    product_id: 1,
                    name: "Mechanical Pencil",
                    quantity: 1,
                    item_price: 90,
                    currency: "USD"
                  }
                ]
              }} = DealProducts.list_page(client, 1)

      assert [%DealProduct{id: 3}] = DealProducts.stream(client, 1) |> Enum.to_list()
    end

    test "maps deal 404", %{client: client} do
      assert {:error, %Error{kind: :not_found}} = DealProducts.list_page(client, 404)
    end
  end

  describe "get/3" do
    test "finds attachment client-side", %{client: client} do
      assert {:ok, %DealProduct{id: 3}} = DealProducts.get(client, 1, 3)
      assert {:error, %Error{kind: :not_found}} = DealProducts.get(client, 1, 999)
    end
  end

  describe "create/3" do
    test "attaches a product", %{client: client} do
      assert {:ok, %DealProduct{deal_id: 1, product_id: 1, quantity: 2, item_price: 90}} =
               DealProducts.create(client, 1, %{
                 product_id: 1,
                 item_price: 90,
                 quantity: 2,
                 ignored: true
               })
    end
  end

  describe "update/4" do
    test "patches an attachment", %{client: client} do
      assert {:ok, %DealProduct{id: 3, quantity: 5}} =
               DealProducts.update(client, 1, 3, %{quantity: 5})
    end

    test "maps 404", %{client: client} do
      assert {:error, %Error{kind: :not_found}} =
               DealProducts.update(client, 1, 404, %{quantity: 1})
    end
  end

  describe "delete/3 and delete_many/3" do
    test "deletes one attachment", %{client: client} do
      assert {:ok, :ok} = DealProducts.delete(client, 1, 3)
      assert {:error, %Error{kind: :not_found}} = DealProducts.delete(client, 1, 404)
    end

    test "deletes many by ids", %{client: client} do
      assert {:ok, [3, 4]} = DealProducts.delete_many(client, 1, ids: [3, 4])
      assert {:ok, [3]} = DealProducts.delete_many(client, 1)
    end
  end
end
