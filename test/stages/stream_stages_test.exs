defmodule ExPipedrive.Stages.StreamStagesTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Page
  alias ExPipedrive.Stage
  alias ExPipedrive.Stages

  describe "list_stages_page/2" do
    test "returns a Page wrapper with next_cursor", %{client: client} do
      assert {:ok, %Page{data: stages, next_cursor: "stages-page-2"}} =
               Stages.list_stages_page(client, limit: 100)

      assert Enum.map(stages, & &1.id) == [1, 2]
      assert Enum.all?(stages, &match?(%Stage{}, &1))
    end

    test "returns the final page when cursor is exhausted", %{client: client} do
      assert {:ok, %Page{data: stages, next_cursor: nil}} =
               Stages.list_stages_page(client, cursor: "stages-page-2")

      assert Enum.map(stages, & &1.id) == [3]
      assert Page.done?(%Page{data: stages, next_cursor: nil})
    end
  end

  describe "stream_stages/2" do
    test "auto-follows cursors until exhausted", %{client: client} do
      stages = client |> Stages.stream_stages(limit: 100) |> Enum.to_list()

      assert Enum.map(stages, & &1.id) == [1, 2, 3]
      assert Enum.all?(stages, &match?(%Stage{}, &1))
    end
  end
end
