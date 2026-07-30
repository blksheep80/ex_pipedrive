defmodule ExPipedrive.Stage do
  @moduledoc """
  Stage entity decoded from Pipedrive API v2 responses.

  Stages belong to a pipeline (`pipeline_id`) and carry deal probability / rot
  settings. The raw payload remains on `original_object`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :name, String.t()
    field :order_nr, integer()
    field :pipeline_id, pos_integer()
    field :is_deleted, boolean()
    field :deal_probability, integer()
    field :is_deal_rot_enabled, boolean()
    field :days_to_rotten, integer()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :update_time, DateTime.t() | NaiveDateTime.t()
    field :original_object, map()
  end

  def handle_transform(map, original_map, opts \\ []) do
    _version = Keyword.get(opts, :version, :auto)

    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.update(:pipeline_id, nil, &normalize_id/1)
    |> Map.put(:original_object, original_map)
  end
end
