defmodule ExPipedrive.ProjectBoards.ProjectBoardsV2Test do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.ProjectBoard
  alias ExPipedrive.ProjectBoards

  describe "get/2" do
    test "returns a typed ProjectBoard from v2", %{client: client} do
      assert {:ok,
              %ProjectBoard{
                id: 1,
                name: "Project Board",
                order_nr: 1
              }} = ProjectBoards.get(client, 1)

      assert %DateTime{} = ProjectBoards.get(client, 1) |> elem(1) |> Map.get(:add_time)
    end

    test "maps missing boards to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = ProjectBoards.get(client, 404)
    end
  end

  describe "list_page/2 and stream/2" do
    test "lists project boards", %{client: client} do
      assert {:ok, page} = ProjectBoards.list_page(client)
      assert length(page.data) == 2
      assert Enum.all?(page.data, &match?(%ProjectBoard{}, &1))
    end

    test "streams boards", %{client: client} do
      names = client |> ProjectBoards.stream() |> Enum.map(& &1.name)
      assert names == ["Project Board", "Second board"]
    end
  end

  describe "create/2" do
    test "creates from a map and returns a ProjectBoard", %{client: client} do
      assert {:ok,
              %ProjectBoard{
                id: 99,
                name: "Delivery board",
                order_nr: 2
              }} =
               ProjectBoards.create(client, %{name: "Delivery board", order_nr: 2})
    end
  end

  describe "update/3" do
    test "patches a board and returns the updated ProjectBoard", %{client: client} do
      assert {:ok, %ProjectBoard{id: 1, name: "Renamed board"}} =
               ProjectBoards.update(client, 1, %{name: "Renamed board"})
    end
  end

  describe "delete/2" do
    test "deletes a project board", %{client: client} do
      assert {:ok, %{"success" => true, "data" => %{"id" => 1}}} =
               ProjectBoards.delete(client, 1)
    end

    test "maps missing deletes to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = ProjectBoards.delete(client, 404)
    end
  end
end
