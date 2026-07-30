defmodule ExPipedrive.Pipeline do
  @moduledoc """
  Pipeline entity decoded from Pipedrive API v1 or v2 responses.

  V2 uses `is_deleted` and `is_deal_probability_enabled` with RFC3339 timestamps.
  V1 fields (`active`, `deal_probability`, `selected`, `url_title`) are retained for
  legacy responses; the raw payload remains on `original_object`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :name, String.t()
    field :order_nr, integer()
    field :is_deleted, boolean()
    field :is_deal_probability_enabled, boolean()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :update_time, DateTime.t() | NaiveDateTime.t()
    # v1 compatibility
    field :active, boolean()
    field :deal_probability, boolean() | float() | integer()
    field :selected, boolean()
    field :url_title, String.t()
    field :original_object, map()
  end

  def handle_transform(map, original_map, opts \\ []) do
    _version = Keyword.get(opts, :version, :auto)

    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> sync_probability_flags()
    |> sync_deleted_flag()
    |> Map.put(:original_object, original_map)
  end

  defp sync_probability_flags(%{is_deal_probability_enabled: nil, deal_probability: value} = map)
       when not is_nil(value) do
    %{map | is_deal_probability_enabled: truthy?(value)}
  end

  defp sync_probability_flags(%{deal_probability: nil, is_deal_probability_enabled: value} = map)
       when not is_nil(value) do
    %{map | deal_probability: value}
  end

  defp sync_probability_flags(map), do: map

  defp sync_deleted_flag(%{is_deleted: nil, active: true} = map), do: %{map | is_deleted: false}
  defp sync_deleted_flag(%{is_deleted: nil, active: false} = map), do: %{map | is_deleted: true}

  defp sync_deleted_flag(%{active: nil, is_deleted: false} = map), do: %{map | active: true}
  defp sync_deleted_flag(%{active: nil, is_deleted: true} = map), do: %{map | active: false}

  defp sync_deleted_flag(map), do: map

  defp truthy?(true), do: true
  defp truthy?(false), do: false
  defp truthy?(value) when is_number(value), do: value != 0
  defp truthy?(_), do: false
end
