defmodule ExPipedrive.Leads.ListLeadsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    Lead,
    Leads,
    PagedResult
  }

  describe "list_leads" do
    test "it forms a correct request and returns the correct data structure results for all leads",
         %{client: client} do
      assert {:ok,
              %PagedResult{
                success: true,
                data: leads,
                additional_data: %{pagination: pagination}
              }} = Leads.list_leads(client)

      assert is_list(leads)

      if length(leads) > 0 do
        assert %Lead{} = hd(leads)
      end

      assert %{start: _, limit: _, more_items_in_collection: _} = pagination
    end

    test "it accepts pagination parameters", %{client: client} do
      assert {:ok,
              %PagedResult{
                success: true,
                additional_data: %{pagination: %{start: 10, limit: 5}}
              }} = Leads.list_leads(client, start: 10, limit: 5)
    end

    test "provides the v1 list alias", %{client: client} do
      assert {:ok, %PagedResult{success: true}} = Leads.list(client)
    end

    test "it accepts filter parameters", %{client: client} do
      # Test with various filter options
      opts = [
        owner_id: 1,
        person_id: 2,
        organization_id: 3,
        filter_id: 4,
        sort: "update_time DESC"
      ]

      assert {:ok, %PagedResult{success: true}} = Leads.list_leads(client, opts)
    end

    test "it handles empty results", %{client: client} do
      # Using a filter that likely returns no results
      assert {:ok,
              %PagedResult{
                success: true,
                data: []
              }} = Leads.list_leads(client, owner_id: 999_999)
    end
  end
end
