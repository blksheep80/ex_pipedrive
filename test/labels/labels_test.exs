defmodule ExPipedrive.LabelsTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Label
  alias ExPipedrive.Labels

  describe "deal labels" do
    test "list/create/update/delete delegate to DealLabels", %{client: client} do
      assert {:ok, [%Label{} | _]} = Labels.list_deal_labels(client)
      assert {:ok, %Label{label: "VIP"}} = Labels.create_deal_label(client, %{label: "VIP"})
      assert {:ok, %Label{id: 1}} = Labels.update_deal_label(client, 1, %{label: "Hot"})
      assert {:ok, %Label{id: 2}} = Labels.delete_deal_label(client, 2)
    end
  end

  describe "person labels" do
    test "list/create/update/delete delegate to PersonLabels", %{client: client} do
      assert {:ok, [%Label{} | _]} = Labels.list_person_labels(client)

      assert {:ok, %Label{label: "Champion"}} =
               Labels.create_person_label(client, %{label: "Champion"})

      assert {:ok, %Label{id: 1}} = Labels.update_person_label(client, 1, %{label: "Customer"})
      assert {:ok, %Label{id: 2}} = Labels.delete_person_label(client, 2)
    end
  end

  describe "organization labels" do
    test "list/create/update/delete delegate to OrganizationLabels", %{client: client} do
      assert {:ok, [%Label{} | _]} = Labels.list_organization_labels(client)

      assert {:ok, %Label{label: "Strategic"}} =
               Labels.create_organization_label(client, %{label: "Strategic"})

      assert {:ok, %Label{id: 1}} =
               Labels.update_organization_label(client, 1, %{label: "Partner"})

      assert {:ok, %Label{id: 2}} = Labels.delete_organization_label(client, 2)
    end
  end

  describe "lead labels" do
    test "list/create/update/delete delegate to LeadLabels", %{client: client} do
      assert {:ok, [%Label{} | _]} = Labels.list_lead_labels(client)
      assert {:ok, %Label{name: "Frozen"}} = Labels.create_lead_label(client, %{name: "Frozen"})

      id = "adf21080-0e10-11eb-879b-05d71fb426ec"
      assert {:ok, %Label{id: ^id}} = Labels.update_lead_label(client, id, %{name: "Hot"})
      assert {:ok, %{"success" => true}} = Labels.delete_lead_label(client, id)
    end
  end
end
