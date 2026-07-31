defmodule ExPipedrive.DealParticipantsTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.DealParticipant
  alias ExPipedrive.DealParticipants
  alias ExPipedrive.PagedResult

  describe "list/2" do
    test "lists participants of a deal", %{client: client} do
      assert {:ok, %PagedResult{data: participants}} = DealParticipants.list(client, 1)

      assert [
               %DealParticipant{id: 1, deal_id: 1, person_id: 101, active_flag: true},
               %DealParticipant{id: 2, deal_id: 1, person_id: 102}
             ] = participants

      assert %DateTime{} = hd(participants).add_time
    end
  end

  describe "add/3" do
    test "adds a participant to a deal", %{client: client} do
      assert {:ok, %DealParticipant{id: 3, deal_id: 1, person_id: 999}} =
               DealParticipants.add(client, 1, 999)
    end
  end

  describe "delete/3" do
    test "removes a participant from a deal", %{client: client} do
      assert {:ok, :ok} = DealParticipants.delete(client, 1, 2)
    end
  end
end
