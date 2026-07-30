defmodule ExPipedrive.Persons.PersonsV2Test do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.Person
  alias ExPipedrive.Persons

  describe "get/2" do
    test "returns a typed Person from v2", %{client: client} do
      assert {:ok, %Person{id: 1, name: "Tim Mecklem", emails: emails, custom_fields: fields}} =
               Persons.get(client, 1)

      assert [%{"value" => "tim@launchscout.com"} | _] = emails
      assert is_map(fields)
    end

    test "maps missing persons to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Persons.get(client, 404)
    end
  end

  describe "create/2" do
    test "creates from a map with emails/phones", %{client: client} do
      assert {:ok, %Person{id: 99, name: "Jane", emails: emails}} =
               Persons.create(client, %{
                 name: "Jane",
                 emails: [%{label: "work", value: "jane@example.com", primary: true}],
                 phones: [%{value: "555-0100", primary: true}]
               })

      assert Enum.any?(emails, fn email ->
               email["value"] == "jane@example.com" or email[:value] == "jane@example.com"
             end)
    end
  end

  describe "update/3" do
    test "patches a person", %{client: client} do
      assert {:ok, %Person{id: 1, name: "Updated Name"}} =
               Persons.update(client, 1, %{name: "Updated Name"})
    end
  end
end
