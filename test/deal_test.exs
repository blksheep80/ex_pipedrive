defmodule ExPipedrive.DealTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Deal

  describe "new/1 v1 shapes" do
    test "it accepts string keys" do
      assert %Deal{id: 45} = Deal.new(%{"id" => 45})
    end

    test "it accepts atom keys" do
      assert %Deal{id: 45} = Deal.new(%{id: 45})
    end

    test "normalizes nested v1 ID objects and parses legacy timestamps" do
      deal =
        Deal.new(%{
          "id" => 1,
          "title" => "Legacy deal",
          "creator_user_id" => %{"id" => 18, "value" => 18, "name" => "User"},
          "user_id" => %{"id" => 18, "value" => 18},
          "person_id" => %{"value" => 9, "name" => "Person"},
          "org_id" => %{"value" => 3, "name" => "Org"},
          "add_time" => "2022-07-09 15:16:27",
          "deleted" => false,
          "visible_to" => "3"
        })

      assert deal.creator_user_id == 18
      assert deal.user_id == 18
      assert deal.owner_id == 18
      assert deal.person_id == 9
      assert deal.org_id == 3
      assert %NaiveDateTime{} = deal.add_time
      assert deal.deleted == false
      assert deal.is_deleted == false
      assert deal.visible_to == 3
      assert deal.original_object["title"] == "Legacy deal"
      assert deal.custom_fields == %{}
    end
  end

  describe "new/1 v2 shapes" do
    test "decodes flat IDs, RFC3339 timestamps, and custom_fields" do
      payload = %{
        "id" => 1,
        "title" => "Deal",
        "value" => 0.0,
        "creator_user_id" => 18,
        "person_id" => 1,
        "org_id" => 1,
        "stage_id" => 2,
        "pipeline_id" => 1,
        "currency" => "USD",
        "add_time" => "2024-07-01T05:46:33Z",
        "update_time" => "2024-07-01T11:29:32Z",
        "status" => "won",
        "visible_to" => 3,
        "owner_id" => 18,
        "label_ids" => [2, 3],
        "is_deleted" => false,
        "custom_fields" => %{
          "53c2f18db6a1655d6af8bba77d9679565f975fd8" => "Text Custom Field",
          "d4de1c1518b4531717c676029a45911c340390a6" => %{
            "value" => 2300,
            "currency" => "EUR"
          }
        }
      }

      assert {:ok, dt, 0} = DateTime.from_iso8601("2024-07-01T05:46:33Z")

      deal = Deal.new(payload)

      assert deal.id == 1
      assert deal.owner_id == 18
      assert deal.user_id == 18
      assert deal.person_id == 1
      assert deal.org_id == 1
      assert deal.creator_user_id == 18
      assert deal.is_deleted == false
      assert deal.deleted == false
      assert deal.label_ids == [2, 3]
      assert deal.add_time == dt
      assert deal.custom_fields["53c2f18db6a1655d6af8bba77d9679565f975fd8"] == "Text Custom Field"

      assert deal.custom_fields["d4de1c1518b4531717c676029a45911c340390a6"] == %{
               "value" => 2300,
               "currency" => "EUR"
             }

      assert deal.original_object == payload
    end

    test "supports explicit version: :v2 option" do
      deal = Deal.new(%{"id" => 7, "owner_id" => 2, "custom_fields" => %{}}, version: :v2)
      assert deal.id == 7
      assert deal.owner_id == 2
    end
  end
end
