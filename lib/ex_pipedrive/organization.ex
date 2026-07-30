defmodule ExPipedrive.Organization do
  @moduledoc """
  Organization entity decoded from Pipedrive API v1 or v2 responses.

  ID references are normalized to integers. V2 `custom_fields` and nested
  `address` objects are supported; the raw payload remains on `original_object`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :owner_id, pos_integer()
    field :name, String.t(), enforce: true
    field :id, pos_integer()
    field :company_id, pos_integer()
    field :open_deals_count, non_neg_integer()
    field :related_open_deals_count, non_neg_integer()
    field :closed_deals_count, non_neg_integer()
    field :related_closed_deals_count, non_neg_integer()
    field :email_messages_count, non_neg_integer()
    field :people_count, non_neg_integer()
    field :activities_count, non_neg_integer()
    field :done_activities_count, non_neg_integer()
    field :undone_activities_count, non_neg_integer()
    field :files_count, non_neg_integer()
    field :notes_count, non_neg_integer()
    field :followers_count, non_neg_integer()
    field :won_deals_count, non_neg_integer()
    field :related_won_deals_count, non_neg_integer()
    field :lost_deals_count, non_neg_integer()
    field :related_lost_deals_count, non_neg_integer()
    field :active_flag, boolean()
    field :is_deleted, boolean()
    field :category_id, pos_integer()
    field :picture_id, pos_integer()
    field :country_code, String.t()
    field :first_char, String.t()
    field :update_time, DateTime.t() | NaiveDateTime.t()
    field :delete_time, DateTime.t() | NaiveDateTime.t()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :visible_to, String.t() | non_neg_integer()
    field :next_activity_date, Date.t()
    field :next_activity_time, Time.t()
    field :next_activity_id, non_neg_integer()
    field :last_activity_id, non_neg_integer()
    field :last_activity_date, Date.t()
    field :label, integer()
    field :label_ids, list()
    field :address, String.t()
    field :address_subpremise, String.t()
    field :address_street_number, String.t()
    field :address_route, String.t()
    field :address_sublocality, String.t()
    field :address_locality, String.t()
    field :address_admin_area_level_1, String.t()
    field :address_admin_area_level_2, String.t()
    field :address_country, String.t()
    field :address_postal_code, String.t()
    field :address_formatted_address, String.t()
    field :owner_name, String.t()
    field :cc_email, String.t()
    field :value, non_neg_integer()
    field :custom_fields, map(), default: %{}
    field :original_object, map()
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(%{id: nil} = org, opts) do
      Jason.Encode.value(Map.take(Map.from_struct(org), [:name, :owner_id]), opts)
    end

    def encode(org, opts), do: Jason.encode(org, opts)
  end

  def handle_transform(map, original_map, opts \\ []) do
    _version = Keyword.get(opts, :version, :auto)

    map
    |> Map.update(:next_activity_date, nil, &parse_date/1)
    |> Map.update(:next_activity_time, nil, &parse_time/1)
    |> Map.update(:last_activity_date, nil, &parse_date/1)
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.update(:delete_time, nil, &parse_datetime/1)
    |> Map.update(:owner_id, nil, &normalize_id/1)
    |> Map.update(:visible_to, nil, &parse_integer/1)
    |> sync_address(original_map)
    |> sync_deleted_flag()
    |> Map.put(:custom_fields, extract_custom_fields(original_map))
    |> Map.put(:original_object, original_map)
  end

  defp sync_address(map, original_map) do
    address =
      case Map.get(original_map, "address") || Map.get(original_map, :address) || map.address do
        %{"value" => value} -> value
        %{value: value} -> value
        value when is_binary(value) -> value
        _ -> map.address
      end

    %{map | address: address}
  end

  defp sync_deleted_flag(%{is_deleted: nil, active_flag: true} = map),
    do: %{map | is_deleted: false}

  defp sync_deleted_flag(%{is_deleted: nil, active_flag: false} = map),
    do: %{map | is_deleted: true}

  defp sync_deleted_flag(map), do: map
end
