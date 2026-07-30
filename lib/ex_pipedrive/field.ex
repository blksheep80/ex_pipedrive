defmodule ExPipedrive.Field do
  @moduledoc """
  A Pipedrive field definition.

  API v2 calls the machine-readable custom field hash `field_code` and its
  human-readable label `field_name`. `key` and `name` mirror those values for
  compatibility with the legacy API v1 field response.
  """

  use TypedStruct
  use ExPipedrive.Structable

  alias ExPipedrive.FieldOption

  typedstruct do
    field :id, pos_integer()
    field :field_code, String.t()
    field :field_name, String.t()
    field :key, String.t()
    field :name, String.t()
    field :order_nr, non_neg_integer()
    field :field_type, String.t()
    field :json_column_flag, boolean()
    field :add_time, NaiveDateTime.t()
    field :update_time, NaiveDateTime.t()
    field :last_updated_by_user_id, pos_integer()
    field :edit_flag, boolean()
    field :details_visible_flag, boolean()
    field :add_visible_flag, boolean()
    field :important_flag, boolean()
    field :bulk_edit_allowed, boolean()
    field :filtering_allowed, boolean()
    field :sortable_flag, boolean()
    field :searchable_flag, boolean()
    field :active_flag, boolean()
    field :mandatory_flag, boolean()
    field :index_visible_flag, boolean()
    field :options, list(FieldOption.t())
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(%{} = field, opts) do
      Jason.Encode.value(Map.take(Map.from_struct(field), [:key, :name]), opts)
    end

    def encode(field, opts), do: Jason.encode(field, opts)
  end

  def handle_transform(map, _) do
    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.update(:options, nil, &map_custom_field_options/1)
    |> sync_field_codes()
    |> sync_field_labels()
  end

  defp sync_field_codes(%{field_code: nil, key: key} = field), do: %{field | field_code: key}

  defp sync_field_codes(%{field_code: field_code, key: nil} = field),
    do: %{field | key: field_code}

  defp sync_field_codes(field), do: field

  defp sync_field_labels(%{field_name: nil, name: name} = field), do: %{field | field_name: name}

  defp sync_field_labels(%{field_name: field_name, name: nil} = field),
    do: %{field | name: field_name}

  defp sync_field_labels(field), do: field

  defp map_custom_field_options(list) when is_list(list) do
    Enum.map(list, &FieldOption.new/1)
  end

  defp map_custom_field_options(_), do: nil
end
