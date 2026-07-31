defmodule ExPipedrive.DealInstallmentsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.DealInstallment
  alias ExPipedrive.DealInstallments
  alias ExPipedrive.Error
  alias ExPipedrive.Page

  describe "list_page/2 and stream/2" do
    test "lists installments for deal ids", %{client: client} do
      assert {:ok,
              %Page{
                data: [
                  %DealInstallment{
                    id: 1,
                    deal_id: 1,
                    description: "Delivery Fee",
                    amount: 10,
                    billing_date: ~D[2025-03-10]
                  }
                ]
              }} = DealInstallments.list_page(client, deal_ids: [1])

      assert [%DealInstallment{id: 1}] =
               DealInstallments.stream(client, deal_ids: [1]) |> Enum.to_list()
    end

    test "maps deal 404", %{client: client} do
      assert {:error, %Error{kind: :not_found}} =
               DealInstallments.list_page(client, deal_ids: [404])
    end
  end

  describe "create/3" do
    test "adds an installment", %{client: client} do
      assert {:ok,
              %DealInstallment{
                deal_id: 1,
                description: "Delivery Fee",
                amount: 10,
                billing_date: ~D[2025-03-10]
              }} =
               DealInstallments.create(client, 1, %{
                 description: "Delivery Fee",
                 amount: 10,
                 billing_date: "2025-03-10",
                 ignored: true
               })

      assert {:error, %Error{kind: :not_found}} =
               DealInstallments.create(client, 404, %{
                 description: "Fee",
                 amount: 10,
                 billing_date: "2025-03-10"
               })
    end
  end

  describe "update/4" do
    test "patches an installment", %{client: client} do
      assert {:ok, %DealInstallment{id: 1, amount: 15}} =
               DealInstallments.update(client, 1, 1, %{amount: 15})

      assert {:error, %Error{kind: :not_found}} =
               DealInstallments.update(client, 1, 404, %{amount: 1})
    end
  end

  describe "delete/3" do
    test "deletes one installment", %{client: client} do
      assert {:ok, :ok} = DealInstallments.delete(client, 1, 1)
      assert {:error, %Error{kind: :not_found}} = DealInstallments.delete(client, 1, 404)
    end
  end
end
