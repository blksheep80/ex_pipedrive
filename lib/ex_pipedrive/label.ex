defmodule ExPipedrive.Label do
  @moduledoc """
  A Pipedrive label.

  Deal, Person, and Organization labels are option values on the system
  `label_ids` field (`label`/`color`); Lead labels come from the dedicated
  `/leadLabels` endpoint (`name`/`color`). `label` and `name` are kept in sync
  so callers can use either regardless of entity type.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, non_neg_integer() | String.t()
    field :label, String.t()
    field :name, String.t()
    field :color, String.t()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :update_time, DateTime.t() | NaiveDateTime.t()
    field :original_object, map()
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(%{} = label, opts) do
      Jason.Encode.value(Map.take(Map.from_struct(label), [:label, :name, :color]), opts)
    end

    def encode(label, opts), do: Jason.encode(label, opts)
  end

  def handle_transform(map, original_map) do
    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> sync_label_and_name()
    |> Map.put(:original_object, original_map)
  end

  defp sync_label_and_name(%{label: nil, name: name} = map) when is_binary(name) do
    %{map | label: name}
  end

  defp sync_label_and_name(%{label: label, name: nil} = map) when is_binary(label) do
    %{map | name: label}
  end

  defp sync_label_and_name(map), do: map
end
