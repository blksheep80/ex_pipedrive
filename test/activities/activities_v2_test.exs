defmodule ExPipedrive.Activities.ActivitiesV2Test do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Activities
  alias ExPipedrive.Activity
  alias ExPipedrive.Error

  describe "get/2" do
    test "returns a typed Activity from v2", %{client: client} do
      assert {:ok,
              %Activity{
                id: 1,
                subject: "Call Mecklem, LLC",
                location: location,
                busy_flag: true,
                busy: true,
                owner_id: 15_783_886,
                custom_fields: fields
              }} = Activities.get(client, 1)

      assert location == "123 Main St, Cincinnati, OH 45202"
      assert is_map(fields)
      assert map_size(fields) > 0
    end

    test "maps missing activities to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Activities.get(client, 404)
    end
  end

  describe "create/2" do
    test "creates from a map and returns an Activity", %{client: client} do
      assert {:ok, %Activity{id: 99, subject: "New call", deal_id: 7, location: location}} =
               Activities.create(client, %{
                 subject: "New call",
                 type: "call",
                 deal_id: 7,
                 location: "1 Infinite Loop"
               })

      assert location == "1 Infinite Loop"
    end

    test "creates from an Activity struct write attrs", %{client: client} do
      assert {:ok, %Activity{id: 99, subject: "From struct"}} =
               Activities.create(client, %Activity{subject: "From struct", type: "call"})
    end
  end

  describe "update/3" do
    test "patches an activity", %{client: client} do
      assert {:ok, %Activity{id: 1, subject: "Updated call", done: true}} =
               Activities.update(client, 1, %{subject: "Updated call", done: true})
    end
  end

  describe "delete/2" do
    test "deletes an activity", %{client: client} do
      assert {:ok, %{"success" => true, "data" => %{"id" => 1}}} = Activities.delete(client, 1)
    end

    test "maps missing deletes to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Activities.delete(client, 404)
    end
  end

  describe "stream/2 alias" do
    test "streams activities via the MVP-friendly name", %{client: client} do
      activities = client |> Activities.stream(limit: 500) |> Enum.to_list()
      assert Enum.map(activities, & &1.id) == [1, 2, 3]
    end
  end
end
