defmodule LineDrive.Incoming.PersonHandler do
  @moduledoc """
  Payload handler for incoming person-related webhook events. This module
  transforms the JSON into `LineDrive.Person` and related structs and returns a
  tuple with the event_type (eg `updated_person`) and transformed payload.
  """

  alias LineDrive.Person

  defmacro __using__(_opts) do
    quote do
      import LineDrive.Incoming.PersonHandler, only: [person_updated: 1]

      def transform_event("updated.person", payload) do
        person_updated(payload)
      end
    end
  end

  def person_updated(%{"current" => person, "meta" => meta, "previous" => previous_person}) do
    person_set = person |> MapSet.new()
    prev_person_set = previous_person |> MapSet.new()
    diff = MapSet.difference(person_set, prev_person_set)

    diff =
      diff
      |> MapSet.to_list()
      |> Map.new()

    {:updated_person,
     %{current: Person.new(person), previous: Person.new(previous_person), meta: meta, diff: diff}}
  end
end
