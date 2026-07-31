defmodule ExPipedrive.ProjectBoard do
  @moduledoc """
  Project board entity decoded from Pipedrive API v2 responses.

  Boards are top-level containers for project phases. Shapes follow
  [Pipedrive OpenAPI v2](https://developers.pipedrive.com/docs/api/v2/openapi.yaml).
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :name, String.t()
    field :order_nr, integer()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :update_time, DateTime.t() | NaiveDateTime.t()
    field :original_object, map()
  end

  def handle_transform(map, original_map, opts \\ []) do
    _version = Keyword.get(opts, :version, :auto)

    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.put(:original_object, original_map)
  end
end
