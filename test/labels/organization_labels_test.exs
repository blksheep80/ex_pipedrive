defmodule ExPipedrive.Labels.OrganizationLabelsTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Label
  alias ExPipedrive.OrganizationLabels

  describe "list/1" do
    test "returns typed labels from the label_ids field options", %{client: client} do
      assert {:ok, [%Label{label: "Partner", color: "blue"}, %Label{label: "Vendor"}]} =
               OrganizationLabels.list(client)
    end
  end

  describe "create/2" do
    test "adds a label and returns it", %{client: client} do
      assert {:ok, %Label{label: "Strategic", color: "purple"}} =
               OrganizationLabels.create(client, %{label: "Strategic", color: "purple"})
    end
  end

  describe "update/3" do
    test "updates a label and returns it", %{client: client} do
      assert {:ok, %Label{id: 1, label: "Key partner"}} =
               OrganizationLabels.update(client, 1, %{label: "Key partner"})
    end
  end

  describe "delete/2" do
    test "deletes a label and returns it", %{client: client} do
      assert {:ok, %Label{id: 2}} = OrganizationLabels.delete(client, 2)
    end
  end
end
