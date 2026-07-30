defmodule ExPipedrive.Stages.StagesV2Test do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.Stage
  alias ExPipedrive.Stages

  describe "get/2" do
    test "returns a typed Stage from v2", %{client: client} do
      assert {:ok,
              %Stage{
                id: 1,
                name: "Qualified",
                pipeline_id: 1,
                deal_probability: 100,
                is_deal_rot_enabled: true
              }} = Stages.get(client, 1)
    end

    test "maps missing stages to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Stages.get(client, 404)
    end
  end

  describe "create/2" do
    test "creates from a map and returns a Stage", %{client: client} do
      assert {:ok,
              %Stage{
                id: 99,
                name: "Proposal",
                pipeline_id: 2,
                deal_probability: 50,
                days_to_rotten: 7
              }} =
               Stages.create(client, %{
                 name: "Proposal",
                 pipeline_id: 2,
                 deal_probability: 50,
                 is_deal_rot_enabled: true,
                 days_to_rotten: 7
               })
    end

    test "creates from a Stage struct write attrs", %{client: client} do
      assert {:ok, %Stage{id: 99, name: "From struct", pipeline_id: 1}} =
               Stages.create(client, %Stage{name: "From struct", pipeline_id: 1})
    end
  end

  describe "update/3" do
    test "patches a stage and returns the updated Stage", %{client: client} do
      assert {:ok, %Stage{id: 1, name: "Won", deal_probability: 100}} =
               Stages.update(client, 1, %{name: "Won", deal_probability: 100})
    end
  end

  describe "delete/2" do
    test "deletes a stage", %{client: client} do
      assert {:ok, %{"success" => true, "data" => %{"id" => 1}}} = Stages.delete(client, 1)
    end

    test "maps missing deletes to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Stages.delete(client, 404)
    end
  end

  describe "stream/2 alias" do
    test "streams stages via the friendly name", %{client: client} do
      stages = client |> Stages.stream(limit: 500) |> Enum.to_list()
      assert Enum.map(stages, & &1.id) == [1, 2, 3]
    end
  end
end
