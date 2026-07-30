defmodule ExPipedrive.PersonTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Person

  describe "new/1 v1 shapes" do
    test "normalizes nested owner/org IDs and keeps original_object" do
      person =
        Person.new(%{
          "id" => 1,
          "name" => "Tim Mecklem",
          "owner_id" => %{"id" => 15_783_886, "value" => 15_783_886},
          "org_id" => %{"value" => 1, "name" => "Mecklem, LLC"},
          "email" => [%{"value" => "tim@example.com", "primary" => true}],
          "phone" => [%{"value" => "555", "primary" => true}],
          "add_time" => "2024-07-01 05:46:33",
          "active_flag" => true,
          "visible_to" => "3"
        })

      assert person.owner_id == 15_783_886
      assert person.org_id == 1
      assert person.primary_email == "tim@example.com"
      assert person.emails == [%{"value" => "tim@example.com", "primary" => true}]
      assert person.phones == [%{"value" => "555", "primary" => true}]
      assert person.is_deleted == false
      assert person.visible_to == 3
      assert %NaiveDateTime{} = person.add_time
      assert person.custom_fields == %{}
      assert person.original_object["name"] == "Tim Mecklem"
    end
  end

  describe "new/1 v2 shapes" do
    test "decodes flat IDs, emails/phones, and custom_fields" do
      payload = %{
        "id" => 1,
        "name" => "First Last",
        "first_name" => "First",
        "last_name" => "Last",
        "owner_id" => 18,
        "org_id" => 1,
        "add_time" => "2024-07-01T05:46:33Z",
        "update_time" => "2024-07-01T11:29:32Z",
        "is_deleted" => false,
        "visible_to" => 3,
        "label_ids" => [2, 3],
        "emails" => [
          %{"value" => "example@email.com", "label" => "work", "primary" => true}
        ],
        "phones" => [
          %{"value" => "55123456", "label" => "work", "primary" => true}
        ],
        "custom_fields" => %{
          "53c2f18db6a1655d6af8bba77d9679565f975fd8" => "VIP"
        }
      }

      assert {:ok, dt, 0} = DateTime.from_iso8601("2024-07-01T05:46:33Z")

      person = Person.new(payload)

      assert person.id == 1
      assert person.owner_id == 18
      assert person.org_id == 1
      assert person.add_time == dt
      assert person.is_deleted == false
      assert person.label_ids == [2, 3]
      assert person.primary_email == "example@email.com"
      assert length(person.emails) == 1
      assert length(person.phones) == 1
      assert person.custom_fields["53c2f18db6a1655d6af8bba77d9679565f975fd8"] == "VIP"
      assert person.original_object == payload
    end
  end
end
