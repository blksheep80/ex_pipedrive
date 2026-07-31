defmodule ExPipedrive.Follower do
  @moduledoc """
  A user following a deal, person, or organization.

  Shared shape across `GET/POST/DELETE /api/v2/{deals,persons,organizations}/:id/followers`.
  Only the id of the followed entity that was requested is populated —
  `deal_id`, `person_id`, and `org_id` are mutually exclusive per call.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :user_id, pos_integer()
    field :deal_id, pos_integer()
    field :person_id, pos_integer()
    field :org_id, pos_integer()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :original_object, map()
  end

  def handle_transform(map, original_map) do
    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:user_id, nil, &normalize_id/1)
    |> Map.update(:deal_id, nil, &normalize_id/1)
    |> Map.update(:person_id, nil, &normalize_id/1)
    |> Map.update(:org_id, nil, &normalize_id/1)
    |> Map.put(:original_object, original_map)
  end
end
