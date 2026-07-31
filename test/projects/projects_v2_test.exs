defmodule ExPipedrive.Projects.ProjectsV2Test do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.Project
  alias ExPipedrive.Projects

  describe "get/2" do
    test "returns a typed Project from v2", %{client: client} do
      assert {:ok,
              %Project{
                id: 3,
                title: "Project",
                status: "open",
                board_id: 1,
                phase_id: 1,
                owner_id: 1,
                deal_ids: [1],
                health_status: 10
              }} = Projects.get(client, 3)

      assert %Date{} = Projects.get(client, 3) |> elem(1) |> Map.get(:start_date)
    end

    test "maps missing projects to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Projects.get(client, 404)
    end
  end

  describe "list_page/2 and stream/2" do
    test "lists non-archived projects with cursor pagination", %{client: client} do
      assert {:ok, page} = Projects.list_page(client, limit: 500)
      assert length(page.data) == 2
      assert page.next_cursor == "projects-page-2"

      assert [project | _] = page.data
      assert %Project{} = project
    end

    test "streams all project pages", %{client: client} do
      ids = client |> Projects.stream(limit: 500) |> Enum.map(& &1.id)
      assert ids == [3, 4, 5]
    end
  end

  describe "list_archived_page/2 and stream_archived/2" do
    test "lists archived projects", %{client: client} do
      assert {:ok, page} = Projects.list_archived_page(client)
      assert [%Project{title: "Archived project", archive_time: %DateTime{}}] = page.data
      assert page.next_cursor == nil
    end

    test "streams archived projects", %{client: client} do
      titles = client |> Projects.stream_archived() |> Enum.map(& &1.title)
      assert titles == ["Archived project"]
    end
  end

  describe "create/2" do
    test "creates from a map and returns a Project", %{client: client} do
      assert {:ok,
              %Project{
                id: 99,
                title: "Office renovation",
                board_id: 1,
                phase_id: 1
              }} =
               Projects.create(client, %{
                 title: "Office renovation",
                 board_id: 1,
                 phase_id: 1
               })
    end
  end

  describe "update/3" do
    test "patches a project and returns the updated Project", %{client: client} do
      assert {:ok, %Project{id: 3, title: "Renamed", status: "completed"}} =
               Projects.update(client, 3, %{title: "Renamed", status: "completed"})
    end
  end

  describe "delete/2" do
    test "deletes a project", %{client: client} do
      assert {:ok, %{"success" => true, "data" => %{"id" => 3}}} = Projects.delete(client, 3)
    end

    test "maps missing deletes to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Projects.delete(client, 404)
    end
  end
end
