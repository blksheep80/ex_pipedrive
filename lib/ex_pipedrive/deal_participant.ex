defmodule ExPipedrive.DealParticipant do
  @moduledoc """
  A person participating in a deal, from `/api/v1/deals/:id/participants`.

  Not to be confused with `ExPipedrive.ActivityParticipant`, which decodes
  the `participants` payload nested inside an activity.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :deal_id, pos_integer()
    field :person_id, pos_integer()
    field :active_flag, boolean()
    field :created_by_user_id, pos_integer()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :original_object, map()
  end

  def handle_transform(map, original_map) do
    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:deal_id, nil, &normalize_id/1)
    |> Map.update(:person_id, nil, &normalize_id/1)
    |> Map.update(:created_by_user_id, nil, &normalize_id/1)
    |> Map.put(:original_object, original_map)
  end
end
