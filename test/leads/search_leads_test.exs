defmodule ExPipedrive.Leads.SearchLeadsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    Lead,
    Leads,
    LeadValue
  }

  describe "search_leads" do
    test "it forms a correct request and returns the correct data structure results for matching leads",
         %{client: client} do
      assert {:ok,
              [
                %Lead{
                  id: "d8648e28-debe-45c8-9725-4e742bfbf2c4",
                  title: "Farkel Deal Lead",
                  person: %{id: 7, name: "Steve Farkel"},
                  organization: %{id: 1, name: "Mecklem, LLC"},
                  value: %LeadValue{amount: 150_000, currency: "USD"}
                }
              ]} = Leads.search_leads(client, "farkel")
    end
  end
end
