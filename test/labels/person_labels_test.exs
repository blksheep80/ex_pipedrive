defmodule ExPipedrive.Labels.PersonLabelsTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Label
  alias ExPipedrive.PersonLabels

  describe "list/1" do
    test "returns typed labels from the label_ids field options", %{client: client} do
      assert {:ok, [%Label{} = customer, %Label{} = lead]} = PersonLabels.list(client)

      assert customer.id == 1
      assert customer.label == "Customer"
      assert customer.color == "green"

      assert lead.label == "Lead"
      assert lead.color == "yellow"
    end
  end

  describe "create/2" do
    test "adds a label and returns it", %{client: client} do
      assert {:ok, %Label{label: "Champion", color: "purple"}} =
               PersonLabels.create(client, %{label: "Champion", color: "purple"})
    end
  end

  describe "update/3" do
    test "updates a label and returns it", %{client: client} do
      assert {:ok, %Label{id: 1, label: "VIP customer"}} =
               PersonLabels.update(client, 1, %{label: "VIP customer"})
    end
  end

  describe "delete/2" do
    test "deletes a label and returns it", %{client: client} do
      assert {:ok, %Label{id: 2}} = PersonLabels.delete(client, 2)
    end
  end
end
