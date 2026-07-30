defmodule ExPipedrive.Pipelines.StreamPipelinesTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Page
  alias ExPipedrive.Pipeline
  alias ExPipedrive.Pipelines

  describe "list_pipelines_page/2" do
    test "returns a Page wrapper with next_cursor", %{client: client} do
      assert {:ok, %Page{data: pipelines, next_cursor: "pipelines-page-2"}} =
               Pipelines.list_pipelines_page(client, limit: 100)

      assert Enum.map(pipelines, & &1.id) == [1, 2]
      assert Enum.all?(pipelines, &match?(%Pipeline{}, &1))
    end

    test "returns the final page when cursor is exhausted", %{client: client} do
      assert {:ok, %Page{data: pipelines, next_cursor: nil}} =
               Pipelines.list_pipelines_page(client, cursor: "pipelines-page-2")

      assert Enum.map(pipelines, & &1.id) == [3]
      assert Page.done?(%Page{data: pipelines, next_cursor: nil})
    end
  end

  describe "stream_pipelines/2" do
    test "auto-follows cursors until exhausted", %{client: client} do
      pipelines = client |> Pipelines.stream_pipelines(limit: 100) |> Enum.to_list()

      assert Enum.map(pipelines, & &1.id) == [1, 2, 3]
      assert Enum.all?(pipelines, &match?(%Pipeline{}, &1))
    end
  end
end
