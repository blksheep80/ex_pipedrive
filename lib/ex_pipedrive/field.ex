defmodule LineDrive.Field do
  @moduledoc """
  This module and enclosed struct represent a person field in pipedrive.
  """

  use TypedStruct
  use LineDrive.Structable

  alias LineDrive.FieldOption

  typedstruct do
    field :id, pos_integer()
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
  end

  defp map_custom_field_options(list) when is_list(list) do
    Enum.map(list, &FieldOption.new/1)
  end

  defp map_custom_field_options(_), do: nil
end
