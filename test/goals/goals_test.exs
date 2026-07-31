defmodule ExPipedrive.GoalsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.Goal
  alias ExPipedrive.Goals

  @goal_id "5665cef556ddff22606fc8f6c0004807"

  @attrs %{
    title: "Some example goal",
    assignee: %{"id" => 123_456, "type" => "company"},
    type: %{"name" => "deals_started", "params" => %{"pipeline_id" => [5, 2]}},
    expected_outcome: %{"target" => 100, "tracking_metric" => "quantity"},
    duration: %{"start" => "2019-11-01", "end" => "2020-10-30"},
    interval: "weekly"
  }

  describe "list/2" do
    test "finds goals via GET /api/v1/goals/find", %{client: client} do
      assert {:ok,
              [
                %Goal{
                  id: @goal_id,
                  owner_id: 987_654,
                  title: "Some example goal",
                  interval: "weekly",
                  is_active: false,
                  type: %{"name" => "Deals started"},
                  assignee: %{"type" => "company"},
                  expected_outcome: %{"target" => 100},
                  duration: %{"start" => "2019-11-01"},
                  report_ids: ["f37bd66a2ab64d28ff6a9b6d2289813a"]
                }
              ]} = Goals.list(client)
    end

    test "passes dot-notation filters as query params", %{client: client} do
      assert {:ok, []} =
               Goals.list(client,
                 title: "no match",
                 type_name: "deals_started",
                 is_active: true,
                 assignee_id: 123_456,
                 assignee_type: "company",
                 period_start: "2020-01-01",
                 period_end: "2020-01-31"
               )
    end
  end

  describe "create/2" do
    test "creates a goal through POST /api/v1/goals", %{client: client} do
      assert {:ok, %Goal{id: @goal_id, title: "Some example goal"}} =
               Goals.create(client, Map.put(@attrs, :ignored, "not sent"))
    end
  end

  describe "update/3" do
    test "updates a goal through PUT /api/v1/goals/:id", %{client: client} do
      assert {:ok, %Goal{id: @goal_id, title: "Renamed goal"}} =
               Goals.update(client, @goal_id, %{title: "Renamed goal"})
    end

    test "maps missing goals to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Goals.update(client, "404", %{title: "Nope"})
    end
  end

  describe "delete/2" do
    test "deletes a goal through DELETE /api/v1/goals/:id", %{client: client} do
      assert {:ok, :ok} = Goals.delete(client, @goal_id)
    end

    test "maps missing goals to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Goals.delete(client, "404")
    end
  end

  describe "get_result/4" do
    test "gets a goal's progress through GET /api/v1/goals/:id/results", %{client: client} do
      assert {:ok, %{progress: 42, goal: %Goal{id: @goal_id, title: "Some example goal"}}} =
               Goals.get_result(client, @goal_id, ~D[2020-01-01], ~D[2020-01-31])
    end

    test "accepts string dates", %{client: client} do
      assert {:ok, %{progress: 42, goal: %Goal{id: @goal_id}}} =
               Goals.get_result(client, @goal_id, "2020-01-01", "2020-01-31")
    end

    test "maps missing goals to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} =
               Goals.get_result(client, "404", ~D[2020-01-01], ~D[2020-01-31])
    end
  end
end
