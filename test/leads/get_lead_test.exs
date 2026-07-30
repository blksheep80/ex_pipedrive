defmodule ExPipedrive.Leads.GetLeadTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    Lead,
    Leads
  }

  describe "get_lead" do
    test "it forms a correct request and returns the correct data structure results for matching lead",
         %{client: client} do
      assert {:ok,
              %Lead{
                id: "d8648e28-debe-45c8-9725-4e742bfbf2c4",
                title: "Farkel Deal Lead",
                person_id: 7,
                organization_id: 1,
                value: %{amount: 150_000, currency: "USD"},
                expected_close_date: ~D[2023-03-01]
              }} = Leads.get_lead(client, "d8648e28-debe-45c8-9725-4e742bfbf2c4")
    end

    test "provides the v1 get alias", %{client: client} do
      assert {:ok, %Lead{id: "d8648e28-debe-45c8-9725-4e742bfbf2c4"}} =
               Leads.get(client, "d8648e28-debe-45c8-9725-4e742bfbf2c4")
    end
  end
end
