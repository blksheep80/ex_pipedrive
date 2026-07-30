defmodule ExPipedrive.Activities.ListActivitiesTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Activities
  alias ExPipedrive.Activity
  alias ExPipedrive.PagedResult

  describe "list_activities" do
    test "it forms a correct request and returns a paged result", %{client: client} do
      assert {:ok,
              %PagedResult{
                success: true,
                data: [%Activity{} | _],
                additional_data: additional_data
              }} =
               Activities.list_activities(client)

      assert additional_data.next_cursor == "MTIzNDU2Nzg5MA=="
      assert additional_data.limit == 100
    end

    test "it accepts cursor and limit parameters", %{client: client} do
      assert {:ok, %PagedResult{success: true}} =
               Activities.list_activities(client,
                 cursor: "MTIzNDU2Nzg5MA==",
                 limit: 50
               )
    end

    test "it accepts cursor, limit, and user_id parameters", %{client: client} do
      assert {:ok, %PagedResult{success: true}} =
               Activities.list_activities(client,
                 cursor: "MTIzNDU2Nzg5MA==",
                 limit: 50,
                 user_id: 123
               )
    end

    test "it accepts done and type parameters", %{client: client} do
      assert {:ok, %PagedResult{success: true}} =
               Activities.list_activities(client,
                 done: true,
                 type: "call"
               )
    end

    test "it accepts multiple types as comma-separated string", %{client: client} do
      assert {:ok, %PagedResult{success: true}} =
               Activities.list_activities(client,
                 type: "call,meeting"
               )
    end
  end
end
