defmodule ExPipedrive.Webhook.EventTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.{
    Activity,
    Deal,
    Lead,
    Note,
    Organization,
    Person,
    Product,
    Project,
    Task
  }

  alias ExPipedrive.Webhook.Event

  describe "deal / person (existing)" do
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
  end

  describe "organization / activity / lead / note / product" do
    test "decodes organization create (v1 added)" do
      payload = %{
        "event" => "added.organization",
        "current" => %{"id" => 9, "name" => "Acme Corp"},
        "previous" => nil,
        "meta" => %{"action" => "added", "object" => "organization"}
      }

      assert {:ok,
              %Event{
                action: "added",
                resource: "organization",
                current: %Organization{id: 9, name: "Acme Corp"},
                previous: nil
              }} = Event.from_payload(payload)
    end

    test "decodes activity update" do
      payload = %{
        "event" => "updated.activity",
        "current" => %{"id" => 3, "subject" => "Call", "type" => "call", "done" => true},
        "previous" => %{"id" => 3, "subject" => "Call", "type" => "call", "done" => false}
      }

      assert {:ok,
              %Event{
                resource: "activity",
                current: %Activity{id: 3, subject: "Call", type: "call", done: true},
                previous: %Activity{done: false},
                diff: %{"done" => true}
              }} = Event.from_payload(payload)
    end

    test "decodes lead change (v2)" do
      payload = %{
        "meta" => %{
          "action" => "change",
          "entity" => "lead",
          "version" => "2.0"
        },
        "data" => %{"id" => "lead-1", "title" => "Inbound"},
        "previous" => %{"title" => "Old title"}
      }

      assert {:ok,
              %Event{
                name: "change.lead",
                action: "change",
                resource: "lead",
                current: %Lead{id: "lead-1", title: "Inbound"},
                previous: %Lead{title: "Old title"}
              }} = Event.from_payload(payload)
    end

    test "decodes note add" do
      payload = %{
        "event" => "added.note",
        "current" => %{"id" => 11, "content" => "Follow up Friday", "deal_id" => 42},
        "previous" => nil
      }

      assert {:ok,
              %Event{
                resource: "note",
                current: %Note{id: 11, content: "Follow up Friday", deal_id: 42},
                previous: nil
              }} = Event.from_payload(payload)
    end

    test "decodes product update" do
      payload = %{
        "event" => "updated.product",
        "current" => %{"id" => 5, "name" => "Widget", "code" => "W-1"},
        "previous" => %{"id" => 5, "name" => "Widget", "code" => "W-0"}
      }

      assert {:ok,
              %Event{
                resource: "product",
                current: %Product{id: 5, name: "Widget", code: "W-1"},
                previous: %Product{code: "W-0"},
                diff: %{"code" => "W-1"}
              }} = Event.from_payload(payload)
    end
  end

  describe "delete and merge actions" do
    test "v1 deleted.person keeps previous typed and current nil" do
      payload = %{
        "event" => "deleted.person",
        "current" => nil,
        "previous" => %{"id" => 7, "name" => "Ada Lovelace"},
        "meta" => %{"action" => "deleted", "object" => "person"}
      }

      assert {:ok,
              %Event{
                action: "deleted",
                resource: "person",
                current: nil,
                previous: %Person{id: 7, name: "Ada Lovelace"},
                diff: %{}
              }} = Event.from_payload(payload)
    end

    test "v2 delete.deal synthesizes name from meta" do
      payload = %{
        "meta" => %{"action" => "delete", "entity" => "deal", "version" => "2.0"},
        "data" => nil,
        "previous" => %{"id" => 42, "title" => "Gone"}
      }

      assert {:ok,
              %Event{
                name: "delete.deal",
                action: "delete",
                resource: "deal",
                current: nil,
                previous: %Deal{id: 42, title: "Gone"}
              }} = Event.from_payload(payload)
    end

    test "v1 merged.organization decodes both sides" do
      payload = %{
        "event" => "merged.organization",
        "current" => %{"id" => 1, "name" => "Survivor"},
        "previous" => %{"id" => 1, "name" => "Survivor", "people_count" => 2}
      }

      assert {:ok,
              %Event{
                action: "merged",
                resource: "organization",
                current: %Organization{id: 1, name: "Survivor"},
                previous: %Organization{people_count: 2}
              }} = Event.from_payload(payload)
    end
  end

  describe "projects / tasks and unknown resources" do
    test "decodes project and task create (v2)" do
      project_payload = %{
        "meta" => %{"action" => "create", "entity" => "project"},
        "data" => %{"id" => 1, "title" => "Onboarding"},
        "previous" => nil
      }

      assert {:ok, %Event{current: %Project{id: 1, title: "Onboarding"}}} =
               Event.from_payload(project_payload)

      task_payload = %{
        "meta" => %{"action" => "create", "entity" => "task"},
        "data" => %{"id" => 2, "title" => "Kickoff", "project_id" => 1},
        "previous" => nil
      }

      assert {:ok, %Event{current: %Task{id: 2, title: "Kickoff", project_id: 1}}} =
               Event.from_payload(task_payload)
    end

    test "keeps unknown resources as maps with raw passthrough" do
      payload = %{
        "meta" => %{"action" => "change", "entity" => "phase"},
        "data" => %{"id" => 3, "name" => "Discovery"},
        "previous" => %{"name" => "Research"}
      }

      assert {:ok,
              %Event{
                name: "change.phase",
                action: "change",
                resource: "phase",
                current: %{"id" => 3, "name" => "Discovery"},
                previous: %{"name" => "Research"},
                raw: ^payload
              }} = Event.from_payload(payload)
    end
  end

  test "typed_resources/0 lists decoded resource keys" do
    assert "deal" in Event.typed_resources()
    assert "organization" in Event.typed_resources()
    assert "lead" in Event.typed_resources()
    refute "phase" in Event.typed_resources()
  end

  test "rejects payloads with no event name or meta action/entity" do
    assert {:error, :invalid_payload} = Event.from_payload(%{"current" => %{}})
  end
end
