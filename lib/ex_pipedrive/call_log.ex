defmodule ExPipedrive.CallLog do
  @moduledoc """
  This module and enclosed structs represent a call log in pipedrive.

  Unlike most Pipedrive entities, `id` is a Pipedrive-generated hex string
  (e.g. `"CAd92b224eb4a39b5ad8fea92ff0e"`), not an integer.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, String.t()
    field :user_id, pos_integer()
    field :activity_id, pos_integer()
    field :subject, String.t()
    field :duration, String.t()
    field :outcome, String.t()
    field :from_phone_number, String.t()
    field :to_phone_number, String.t()
    field :has_recording, boolean()
    field :start_time, DateTime.t()
    field :end_time, DateTime.t()
    field :person_id, pos_integer()
    field :org_id, pos_integer()
    field :deal_id, pos_integer()
    field :lead_id, String.t()
    field :note, String.t()
    field :company_id, pos_integer()
    field :original_object, map()
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:start_time, nil, &parse_datetime/1)
    |> Map.update(:end_time, nil, &parse_datetime/1)
    |> Map.put(:original_object, original)
  end
end
