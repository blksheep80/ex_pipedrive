defmodule ExPipedrive.Pipelines.ListPipelineDealsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.{
    Deal,
    Pipelines
  }

  describe "list_pipeline_deals" do
    test "it forms a correct request and returns a list of deals in a pipeline", %{client: client} do
      assert {:ok, [%Deal{title: "Mecklem, LLC deal"}]} = Pipelines.list_pipeline_deals(client, 1)
    end
  end
end
