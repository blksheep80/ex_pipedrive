defmodule ExPipedrive.Person do
  @moduledoc """
  Person entity decoded from Pipedrive API v1 or v2 responses.

  ID references are normalized to integers. V2 `custom_fields`, `emails`, and
  `phones` are first-class; the raw payload remains on `original_object`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  alias ExPipedrive.Organization

  typedstruct do
    field :id, pos_integer()
    field :name, String.t(), enforce: true
    field :owner_id, pos_integer()
    field :primary_email, String.t()
    # search returns an organization map
    field :organization, Organization.t()
    field :org_name, String.t()
    field :org_id, pos_integer()

    field :company_id, pos_integer()
    field :first_name, String.t()
    field :last_name, String.t()
    field :open_deals_count, non_neg_integer()
    field :related_open_deals_count, non_neg_integer()
    field :closed_deals_count, non_neg_integer()
    field :related_closed_deals_count, non_neg_integer()
    field :participant_open_deals_count, non_neg_integer()
    field :participant_closed_deals_count, non_neg_integer()
    field :email_messages_count, non_neg_integer()
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
    field :update_time, DateTime.t() | NaiveDateTime.t()
    field :delete_time, DateTime.t() | NaiveDateTime.t()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :visible_to, String.t() | non_neg_integer()
    field :next_activity_date, Date.t()
    field :next_activity_time, Time.t()
    field :next_activity_id, pos_integer()
    field :last_activity_id, pos_integer()
    field :last_activity_date, Date.t()
    field :last_incoming_mail_time, DateTime.t() | NaiveDateTime.t()
    field :last_outgoing_mail_time, DateTime.t() | NaiveDateTime.t()
    field :label, non_neg_integer() | String.t()
    field :label_ids, list()
    field :owner_name, String.t()
    field :emails, list(), default: []
    field :phones, list(), default: []
    field :custom_fields, map(), default: %{}

    field :original_object, map()
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(%{id: nil} = person, opts) do
      Jason.Encode.value(Map.take(Map.from_struct(person), [:name, :owner_id]), opts)
    end

    def encode(person, opts), do: Jason.encode(person, opts)
  end

  def new_from_search(map) do
    map
    |> atomize_keys()
    |> Map.update(:organization, nil, &Organization.new/1)
    |> Map.update(:org_id, nil, &normalize_id/1)
    |> Map.update(:owner_id, nil, &normalize_id/1)
    |> Map.put(:custom_fields, extract_custom_fields(map))
    |> Map.put(:original_object, map)
    |> then(&struct(__MODULE__, &1))
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
    |> Map.update(:last_incoming_mail_time, nil, &parse_datetime/1)
    |> Map.update(:last_outgoing_mail_time, nil, &parse_datetime/1)
    |> Map.update(:org_id, nil, &normalize_id/1)
    |> Map.update(:owner_id, nil, &normalize_id/1)
    |> Map.update(:visible_to, nil, &parse_integer/1)
    |> sync_contact_lists(original_map)
    |> sync_deleted_flag()
    |> Map.put(:custom_fields, extract_custom_fields(original_map))
    |> Map.put(:original_object, original_map)
  end

  defp sync_contact_lists(map, original_map) do
    emails =
      Map.get(map, :emails) ||
        Map.get(original_map, "emails") ||
        Map.get(original_map, "email") ||
        []

    phones =
      Map.get(map, :phones) ||
        Map.get(original_map, "phones") ||
        Map.get(original_map, "phone") ||
        []

    primary_email =
      map.primary_email ||
        primary_contact_value(emails)

    %{map | emails: List.wrap(emails), phones: List.wrap(phones), primary_email: primary_email}
  end

  defp primary_contact_value(list) when is_list(list) do
    Enum.find_value(list, fn
      %{"primary" => true, "value" => value} -> value
      %{primary: true, value: value} -> value
      %{"value" => value} -> value
      %{value: value} -> value
      _ -> nil
    end)
  end

  defp primary_contact_value(_), do: nil

  defp sync_deleted_flag(%{is_deleted: nil, active_flag: true} = map),
    do: %{map | is_deleted: false}

  defp sync_deleted_flag(%{is_deleted: nil, active_flag: false} = map),
    do: %{map | is_deleted: true}

  defp sync_deleted_flag(map), do: map
end
