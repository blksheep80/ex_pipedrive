defmodule ExPipedrive.Persons.StreamPersonsTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Page
  alias ExPipedrive.Person
  alias ExPipedrive.Persons

  test "list_persons_page/2 and stream_persons/2 follow cursors", %{client: client} do
    assert {:ok, %Page{data: [p1 | _], next_cursor: "persons-page-2"}} =
             Persons.list_persons_page(client)

    assert %Person{id: 1} = p1

    people = client |> Persons.stream_persons() |> Enum.to_list()
    assert Enum.map(people, & &1.id) == [1, 2, 3]
  end
end
