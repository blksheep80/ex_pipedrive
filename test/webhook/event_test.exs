defmodule ExPipedrive.Webhook.EventTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.{Deal, Person}
  alias ExPipedrive.Webhook.Event

  test "normalizes a v1 deal update and decodes its typed payload" do
    payload = %{
      "event" => "updated.deal",
      "current" => %{"id" => 42, "title" => "Renewal", "value" => 100},
      "previous" => %{"id" => 42, "title" => "Renewal", "value" => 90},
      "meta" => %{"webhook_id" => "webhook-1"}
    }

    assert {:ok,
            %Event{
              name: "updated.deal",
              action: "updated",
              resource: "deal",
              current: %Deal{id: 42, value: 100},
              previous: %Deal{id: 42, value: 90},
              diff: %{"value" => 100}
            }} = Event.from_payload(payload)
  end

  test "accepts a v2-ish resource.action event and data payload" do
    payload = %{
      "event_type" => "person.updated",
      "data" => %{"id" => 7, "name" => "Ada Lovelace"},
      "meta" => %{"object" => "person", "action" => "updated"}
    }

    assert {:ok,
            %Event{
              name: "person.updated",
              action: "updated",
              resource: "person",
              current: %Person{id: 7, name: "Ada Lovelace"},
              previous: nil
            }} = Event.from_payload(payload)
  end

  test "rejects payloads with no event name" do
    assert {:error, :invalid_payload} = Event.from_payload(%{"current" => %{}})
  end
end
