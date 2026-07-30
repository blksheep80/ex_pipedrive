defmodule ExPipedrive.ActivityParticipant do
  @moduledoc """
  Activity participant decoded from Pipedrive API v1 or v2 responses.

  V2 uses `primary`; legacy payloads use `primary_flag`. Both are synced.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :person_id, pos_integer()
    field :primary_flag, boolean()
    field :primary, boolean()
  end

  def handle_transform(map, original_map, opts \\ []) do
    _ = opts

    primary =
      Map.get(map, :primary) ||
        Map.get(map, :primary_flag) ||
        Map.get(original_map, "primary") ||
        Map.get(original_map, "primary_flag")

    map
    |> Map.put(:primary, primary)
    |> Map.put(:primary_flag, primary)
    |> Map.update(:person_id, nil, &normalize_id/1)
  end
end
