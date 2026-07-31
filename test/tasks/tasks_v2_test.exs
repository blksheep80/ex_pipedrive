defmodule ExPipedrive.Tasks.TasksV2Test do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.Page
  alias ExPipedrive.Task
  alias ExPipedrive.Tasks

  describe "list_page/2 and stream/2" do
    test "lists tasks with cursor pagination", %{client: client} do
      assert {:ok,
              %Page{
                data: [
                  %Task{id: 1, title: "Task 1", project_id: 1},
                  %Task{id: 2, title: "Task 2", project_id: 1}
                ],
                next_cursor: "tasks-page-2"
              }} = Tasks.list_page(client)

      assert [%Task{id: 3}] = Tasks.stream(client, cursor: "tasks-page-2") |> Enum.to_list()
    end
  end

  describe "get/2" do
    test "returns a typed task", %{client: client} do
      assert {:ok,
              %Task{
                id: 1,
                title: "Task 1",
                creator_id: 2,
                description: "Task description",
                project_id: 1,
                is_done: false,
                is_milestone: false,
                due_date: ~D[2026-10-11],
                start_date: ~D[2026-09-01],
                assignee_ids: [2, 3]
              }} = Tasks.get(client, 1)

      assert {:ok, %Task{add_time: add_time}} = Tasks.get(client, 1)
      assert %DateTime{} = add_time
    end

    test "maps missing tasks to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Tasks.get(client, 404)
    end
  end

  describe "create/2" do
    test "creates a task", %{client: client} do
      assert {:ok, %Task{id: 99, title: "Ship v0.3", project_id: 1, assignee_ids: [2]}} =
               Tasks.create(client, %{
                 title: "Ship v0.3",
                 project_id: 1,
                 assignee_ids: [2],
                 ignored: true
               })
    end
  end

  describe "update/3" do
    test "patches a task", %{client: client} do
      assert {:ok, %Task{id: 1, title: "Updated task", is_done: true}} =
               Tasks.update(client, 1, %{title: "Updated task", done: 1})

      assert {:error, %Error{status: 404}} = Tasks.update(client, 404, %{title: "Missing"})
    end
  end

  describe "delete/2" do
    test "deletes a task", %{client: client} do
      assert {:ok, :ok} = Tasks.delete(client, 1)
      assert {:error, %Error{status: 404}} = Tasks.delete(client, 404)
    end
  end
end
