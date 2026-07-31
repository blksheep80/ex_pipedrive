defmodule ExPipedrive.ActivityTypes.ListActivityTypesTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.ActivityType
  alias ExPipedrive.ActivityTypes
  alias ExPipedrive.Error

  describe "list/1" do
    test "returns activity types", %{client: client} do
      assert {:ok, [%ActivityType{name: "Call", key_string: "call", icon_key: "call"} | _]} =
               ActivityTypes.list(client)
    end

    test "list_activity_types/1 aliases list/1", %{client: client} do
      assert {:ok, [%ActivityType{name: "Call"} | _]} =
               ActivityTypes.list_activity_types(client)
    end
  end

  describe "get/2" do
    test "looks up by id client-side", %{client: client} do
      assert {:ok, %ActivityType{id: 1, name: "Call"}} = ActivityTypes.get(client, 1)
      assert {:error, %Error{kind: :not_found}} = ActivityTypes.get(client, 999)
    end
  end

  describe "create/2" do
    test "creates a custom activity type", %{client: client} do
      assert {:ok,
              %ActivityType{
                id: 12,
                name: "Video call",
                key_string: "video_call",
                icon_key: "camera",
                color: "aeb31b",
                is_custom_flag: true
              }} =
               ActivityTypes.create(client, %{
                 name: "Video call",
                 icon_key: "camera",
                 color: "aeb31b",
                 ignored: "drop"
               })
    end
  end

  describe "update/3" do
    test "updates an activity type", %{client: client} do
      assert {:ok, %ActivityType{id: 12, order_nr: 10, name: "Video call"}} =
               ActivityTypes.update(client, 12, %{order_nr: 10})
    end

    test "maps 404", %{client: client} do
      assert {:error, %Error{kind: :not_found}} =
               ActivityTypes.update(client, 404, %{name: "Nope"})
    end
  end

  describe "delete/2" do
    test "deletes an activity type", %{client: client} do
      assert {:ok, :ok} = ActivityTypes.delete(client, 12)
    end

    test "maps 404", %{client: client} do
      assert {:error, %Error{kind: :not_found}} = ActivityTypes.delete(client, 404)
    end
  end
end
