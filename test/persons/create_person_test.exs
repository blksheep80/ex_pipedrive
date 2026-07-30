defmodule ExPipedrive.Contacts.CreatePersonTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.Person
  alias ExPipedrive.Persons

  describe "create_persons" do
    test "it forms a correct request and returns the correct data structure results for new person",
         %{client: client} do
      assert {:ok, %Person{id: 1, name: "New Person"}} =
               Persons.create_person(client, %Person{name: "New Person"})
    end
  end
end
