defmodule ExPipedrive.Notes.GetAllOrgNotesTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Note
  alias ExPipedrive.Notes
  alias ExPipedrive.PagedResult

  test "get_all_org_notes returns a PagedResult of notes for the organization", %{
    client: client
  } do
    assert {:ok, %PagedResult{success: true, data: notes, additional_data: additional_data}} =
             Notes.get_all_org_notes(client, org_id: 1)

    assert [
             %Note{
               id: 2,
               org_id: 1,
               content: "Met them at such and such event",
               pinned_to_organization_flag: true
             },
             %Note{
               id: 1,
               org_id: 1,
               content: "Talked with them and they told me they are using elixir",
               pinned_to_organization_flag: false
             }
           ] = notes

    assert %{start: 0, more_items_in_collection: true} = additional_data.pagination
  end

  test "get_all_org_notes/2 with org_id matches list/2 shape", %{client: client} do
    assert {:ok, %PagedResult{data: notes}} = Notes.get_all_org_notes(client, 1)
    assert {:ok, %PagedResult{data: ^notes}} = Notes.list(client, org_id: 1, limit: 20)
  end
end
