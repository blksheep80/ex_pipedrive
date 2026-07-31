defmodule ExPipedrive.Project do
  @moduledoc """
  Project entity decoded from Pipedrive API v2 responses.

  Shapes follow [Pipedrive OpenAPI v2](https://developers.pipedrive.com/docs/api/v2/openapi.yaml)
  (`Project`). Custom fields remain on `custom_fields`; the raw payload is on
  `original_object`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :title, String.t()
    field :description, String.t()
    field :status, String.t()
    field :board_id, pos_integer()
    field :phase_id, pos_integer()
    field :owner_id, pos_integer()
    field :start_date, Date.t()
    field :end_date, Date.t()
    field :deal_ids, list(pos_integer()), default: []
    field :person_ids, list(pos_integer()), default: []
    field :org_ids, list(pos_integer()), default: []
    field :label_ids, list(pos_integer()), default: []
    field :health_status, integer() | nil
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :update_time, DateTime.t() | NaiveDateTime.t()
    field :status_change_time, DateTime.t() | NaiveDateTime.t()
    field :archive_time, DateTime.t() | NaiveDateTime.t() | nil
    field :custom_fields, map(), default: %{}
    field :original_object, map()
  end

  def handle_transform(map, original_map, opts \\ []) do
    _version = Keyword.get(opts, :version, :auto)

    map
    |> Map.update(:start_date, nil, &parse_date/1)
    |> Map.update(:end_date, nil, &parse_date/1)
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.update(:status_change_time, nil, &parse_datetime/1)
    |> Map.update(:archive_time, nil, &parse_datetime/1)
    |> Map.update(:board_id, nil, &normalize_id/1)
    |> Map.update(:phase_id, nil, &normalize_id/1)
    |> Map.update(:owner_id, nil, &normalize_id/1)
    |> Map.update(:deal_ids, [], &normalize_id_list/1)
    |> Map.update(:person_ids, [], &normalize_id_list/1)
    |> Map.update(:org_ids, [], &normalize_id_list/1)
    |> Map.update(:label_ids, [], &normalize_id_list/1)
    |> Map.put(:custom_fields, extract_custom_fields(original_map))
    |> Map.put(:original_object, original_map)
  end

  defp normalize_id_list(nil), do: []
  defp normalize_id_list(ids) when is_list(ids), do: Enum.map(ids, &normalize_id/1)
  defp normalize_id_list(_), do: []
end
