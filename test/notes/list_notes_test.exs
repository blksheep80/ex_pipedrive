defmodule ExPipedrive.Notes.ListNotesTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    Note,
    Notes,
    PagedResult
  }

  describe "list_notes" do
    test "it forms a correct request and returns the correct data structure results for all notes",
         %{client: client} do
      assert {:ok,
              %PagedResult{
                success: true,
                data: notes,
                additional_data: %{pagination: pagination}
              }} = Notes.list_notes(client)

      assert is_list(notes)

      if length(notes) > 0 do
        assert %Note{} = hd(notes)
      end

      assert %{start: _, limit: _, more_items_in_collection: _} = pagination
    end

    test "it accepts pagination parameters", %{client: client} do
      assert {:ok,
              %PagedResult{
                success: true,
                additional_data: %{pagination: %{start: 10, limit: 5}}
              }} = Notes.list_notes(client, start: 10, limit: 5)
    end

    test "provides the v1 list alias", %{client: client} do
      assert {:ok, %PagedResult{success: true}} = Notes.list(client)
    end

    test "it accepts filter parameters", %{client: client} do
      # Test with various filter options
      opts = [
        user_id: 123,
        org_id: 1,
        person_id: 7,
        deal_id: 1,
        sort: "add_time DESC"
      ]

      assert {:ok, %PagedResult{success: true}} = Notes.list_notes(client, opts)
    end

    test "it accepts pinning flags", %{client: client} do
      opts = [
        pinned_to_organization_flag: 1,
        pinned_to_person_flag: 0,
        pinned_to_deal_flag: 0,
        pinned_to_lead_flag: 0
      ]

      assert {:ok, %PagedResult{success: true}} = Notes.list_notes(client, opts)
    end
  end
end
