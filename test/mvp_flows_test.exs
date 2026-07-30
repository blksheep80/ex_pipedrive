defmodule ExPipedrive.MvpFlowsTest do
  @moduledoc """
  End-to-end fake-server coverage for the two v0.1 MVP proof flows.
  """
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Deal
  alias ExPipedrive.Deals
  alias ExPipedrive.Person
  alias ExPipedrive.Persons

  test "flow 1: stream all open deals via cursor pagination", %{client: client} do
    deals =
      client
      |> Deals.stream(status: "open", limit: 500)
      |> Enum.to_list()

    assert length(deals) == 3
    assert Enum.all?(deals, &match?(%Deal{status: "open"}, &1))
  end

  test "flow 2: create person then deal with person_id", %{client: client} do
    assert {:ok, %Person{id: person_id} = person} =
             Persons.create(client, %{
               name: "Jane Doe",
               emails: [%{"label" => "work", "value" => "jane@example.com", "primary" => true}]
             })

    assert person_id == 99

    assert {:ok, %Deal{id: 99, title: "Jane opportunity", person_id: ^person_id}} =
             Deals.create(client, %{
               title: "Jane opportunity",
               person_id: person.id,
               value: 2500.0,
               currency: "USD"
             })
  end
end
