defmodule ExPipedrive.Labels.DealLabelsTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.DealLabels
  alias ExPipedrive.Label

  describe "list/1" do
    test "returns typed labels from the label_ids field options", %{client: client} do
      assert {:ok, [%Label{} = hot, %Label{} = cold]} = DealLabels.list(client)

      assert hot.id == 1
      assert hot.label == "Hot"
      assert hot.name == "Hot"
      assert hot.color == "red"
      assert %DateTime{} = hot.add_time

      assert cold.label == "Cold"
      assert cold.color == "blue"
    end
  end

  describe "create/2" do
    test "adds a label and returns it", %{client: client} do
      assert {:ok, %Label{label: "VIP", color: "purple"}} =
               DealLabels.create(client, %{label: "VIP", color: "purple"})
    end
  end

  describe "update/3" do
    test "updates a label and returns it", %{client: client} do
      assert {:ok, %Label{id: 1, label: "Scorching", color: "red"}} =
               DealLabels.update(client, 1, %{label: "Scorching"})
    end
  end

  describe "delete/2" do
    test "deletes a label and returns it", %{client: client} do
      assert {:ok, %Label{id: 2}} = DealLabels.delete(client, 2)
    end
  end
end
