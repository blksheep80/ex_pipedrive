defmodule ExPipedrive.WebhooksTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.Webhooks
  alias ExPipedrive.Webhooks.Subscription

  describe "list/1" do
    test "lists API v1 webhook subscriptions", %{client: client} do
      assert {:ok,
              [
                %Subscription{
                  id: 42,
                  subscription_url: "https://example.test/pipedrive/webhooks",
                  event_action: "change",
                  event_object: "deal",
                  version: "2.0"
                }
              ]} = Webhooks.list(client)
    end
  end

  describe "create/2" do
    test "creates an API v1 webhook subscription", %{client: client} do
      assert {:ok,
              %Subscription{
                id: 42,
                name: "Person changes",
                event_action: "change",
                event_object: "person",
                version: "2.0"
              }} =
               Webhooks.create(client, %{
                 subscription_url: "https://example.test/pipedrive/webhooks",
                 event_action: "change",
                 event_object: "person",
                 name: "Person changes",
                 version: "2.0",
                 ignored: "not sent"
               })
    end
  end

  describe "delete/2" do
    test "deletes an API v1 webhook subscription", %{client: client} do
      assert {:ok, :ok} = Webhooks.delete(client, 42)
    end

    test "maps missing subscriptions to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Webhooks.delete(client, 404)
    end
  end
end
