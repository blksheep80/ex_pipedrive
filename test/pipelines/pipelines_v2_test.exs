defmodule ExPipedrive.Pipelines.PipelinesV2Test do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.Pipeline
  alias ExPipedrive.Pipelines

  describe "get/2" do
    test "returns a typed Pipeline from v2", %{client: client} do
      assert {:ok,
              %Pipeline{
                id: 1,
                name: "Pipeline",
                is_deleted: false,
                is_deal_probability_enabled: true
              }} = Pipelines.get(client, 1)
    end

    test "maps missing pipelines to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Pipelines.get(client, 404)
    end
  end

  describe "create/2" do
    test "creates from a map and returns a Pipeline", %{client: client} do
      assert {:ok,
              %Pipeline{
                id: 99,
                name: "Enterprise Pipeline",
                is_deal_probability_enabled: false
              }} =
               Pipelines.create(client, %{
                 name: "Enterprise Pipeline",
                 is_deal_probability_enabled: false
               })
    end

    test "creates from a Pipeline struct write attrs", %{client: client} do
      assert {:ok, %Pipeline{id: 99, name: "From struct"}} =
               Pipelines.create(client, %Pipeline{name: "From struct"})
    end
  end

  describe "update/3" do
    test "patches a pipeline and returns the updated Pipeline", %{client: client} do
      assert {:ok, %Pipeline{id: 1, name: "Renamed", is_deal_probability_enabled: false}} =
               Pipelines.update(client, 1, %{
                 name: "Renamed",
                 is_deal_probability_enabled: false
               })
    end
  end

  describe "delete/2" do
    test "deletes a pipeline", %{client: client} do
      assert {:ok, %{"success" => true, "data" => %{"id" => 1}}} = Pipelines.delete(client, 1)
    end

    test "maps missing deletes to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Pipelines.delete(client, 404)
    end
  end

  describe "stream/2 alias" do
    test "streams pipelines via the friendly name", %{client: client} do
      pipelines = client |> Pipelines.stream(limit: 500) |> Enum.to_list()
      assert Enum.map(pipelines, & &1.id) == [1, 2, 3]
    end
  end
end
