defmodule ExPipedrive.Leads.CreateLeadTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    Lead,
    Leads
  }

  describe "create_lead" do
    test "it forms a correct request and returns the correct data structure results for new lead",
         %{client: client} do
      assert {:ok,
              %Lead{
                id: "d8648e28-debe-45c8-9725-4e742bfbf2c4",
                title: "Farkel Deal Lead",
                person_id: 7,
                organization_id: 1,
                expected_close_date: ~D[2023-03-01],
                value: %{amount: 150_000, currency: "USD"}
              }} =
               Leads.create_lead(client, %Lead{
                 title: "Farkel Deal Lead",
                 expected_close_date: ~D[2023-03-01],
                 person_id: 7,
                 organization_id: 1,
                 value: %{amount: 150_000, currency: "USD"}
               })
    end
  end
end
