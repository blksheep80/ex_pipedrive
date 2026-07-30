defmodule ExPipedrive.Pipelines.ListPipelinesTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.{
    Pipeline,
    Pipelines
  }

  describe "list_pipelines" do
    test "it forms a correct request and returns a list of pipelines", %{client: client} do
      assert {:ok, [%Pipeline{name: "Pipeline"}]} = Pipelines.list_pipelines(client)
    end
  end
end
