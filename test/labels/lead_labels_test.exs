defmodule ExPipedrive.Labels.LeadLabelsTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Label
  alias ExPipedrive.LeadLabels

  describe "list/1" do
    test "returns all lead labels", %{client: client} do
      assert {:ok, [%Label{} = hot, %Label{} = warm]} = LeadLabels.list(client)

      assert hot.name == "Hot"
      assert hot.label == "Hot"
      assert hot.color == "red"

      assert warm.name == "Warm"
      assert warm.color == "yellow"
    end
  end

  describe "create/2" do
    test "creates a lead label and returns it", %{client: client} do
      assert {:ok, %Label{name: "Frozen", color: "blue"}} =
               LeadLabels.create(client, %{name: "Frozen", color: "blue"})
    end
  end

  describe "update/3" do
    test "updates a lead label and returns it", %{client: client} do
      id = "adf21080-0e10-11eb-879b-05d71fb426ec"

      assert {:ok, %Label{id: ^id, name: "Scorching"}} =
               LeadLabels.update(client, id, %{name: "Scorching"})
    end
  end

  describe "delete/2" do
    test "deletes a lead label", %{client: client} do
      id = "adf21080-0e10-11eb-879b-05d71fb426ec"
      assert {:ok, %{"success" => true, "data" => %{"id" => ^id}}} = LeadLabels.delete(client, id)
    end
  end
end
