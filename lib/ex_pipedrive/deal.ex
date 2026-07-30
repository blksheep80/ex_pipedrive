defmodule ExPipedrive.Deal do
  @moduledoc """
  Deal entity decoded from Pipedrive API v1 or v2 responses.

  ID references are normalized to integers (v1 nested `{value: ...}` objects or
  flat v2 IDs). Custom fields live under `custom_fields` for v2; the raw payload
  is always available as `original_object`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :expected_close_date, Date.t()
    field :id, non_neg_integer()
    field :pipeline_id, non_neg_integer()
    field :stage_id, non_neg_integer()
    field :status, String.t()
    field :title, String.t()
    field :value, float()
    field :weighted_value, float()
    field :currency, String.t()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :update_time, DateTime.t() | NaiveDateTime.t()
    field :stage_change_time, DateTime.t() | NaiveDateTime.t()
    field :active, boolean()
    field :deleted, boolean()
    field :is_deleted, boolean()
    field :probability, non_neg_integer()
    field :next_activity_date, Date.t()
    field :next_activity_time, Time.t()
    field :next_activity_id, non_neg_integer()
    field :last_activity_id, non_neg_integer()
    field :last_activity_date, Date.t()
    field :lost_reason, String.t()
    field :visible_to, non_neg_integer()
    field :close_time, DateTime.t() | NaiveDateTime.t()
    field :won_time, DateTime.t() | NaiveDateTime.t()
    field :first_won_time, DateTime.t() | NaiveDateTime.t()
    field :lost_time, DateTime.t() | NaiveDateTime.t()
    field :products_count, non_neg_integer()
    field :files_count, non_neg_integer()
    field :notes_count, non_neg_integer()
    field :followers_count, non_neg_integer()
    field :email_messages_count, non_neg_integer()
    field :activities_count, non_neg_integer()
    field :done_activities_count, non_neg_integer()
    field :undone_activities_count, non_neg_integer()
    field :participants_count, non_neg_integer()
    field :last_incoming_mail_time, DateTime.t() | NaiveDateTime.t()
    field :last_outgoing_mail_time, DateTime.t() | NaiveDateTime.t()
    field :label, String.t()
    field :label_ids, list()
    field :stage_order_nr, non_neg_integer()
    field :person_name, String.t()
    field :org_name, String.t()
    field :next_activity_subject, String.t()
    field :next_activity_type, String.t()
    field :next_activity_duration, String.t()
    field :next_activity_note, String.t()
    field :formatted_value, String.t()
    field :formatted_weighted_value, String.t()
    field :weighted_value_currency, String.t()
    field :rotten_time, String.t()
    field :owner_name, String.t()
    field :cc_email, String.t()
    field :org_hidden, boolean()
    field :person_hidden, boolean()
    field :creator_user_id, non_neg_integer()
    field :user_id, non_neg_integer()
    field :owner_id, non_neg_integer()
    field :person_id, non_neg_integer()
    field :org_id, non_neg_integer()
    field :custom_fields, map(), default: %{}
    field :original_object, map()
  end

  def handle_transform(map, original_map, opts \\ []) do
    _version = Keyword.get(opts, :version, :auto)

    map
    |> Map.update(:expected_close_date, nil, &parse_date/1)
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:stage_change_time, nil, &parse_datetime/1)
    |> Map.update(:next_activity_date, nil, &parse_date/1)
    |> Map.update(:next_activity_time, nil, &parse_time/1)
    |> Map.update(:last_activity_date, nil, &parse_date/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.update(:close_time, nil, &parse_datetime/1)
    |> Map.update(:won_time, nil, &parse_datetime/1)
    |> Map.update(:first_won_time, nil, &parse_datetime/1)
    |> Map.update(:lost_time, nil, &parse_datetime/1)
    |> Map.update(:last_incoming_mail_time, nil, &parse_datetime/1)
    |> Map.update(:last_outgoing_mail_time, nil, &parse_datetime/1)
    |> Map.update(:creator_user_id, nil, &normalize_id/1)
    |> Map.update(:user_id, nil, &normalize_id/1)
    |> Map.update(:owner_id, nil, &normalize_id/1)
    |> Map.update(:person_id, nil, &normalize_id/1)
    |> Map.update(:org_id, nil, &normalize_id/1)
    |> Map.update(:visible_to, nil, &parse_integer/1)
    |> sync_owner_ids()
    |> sync_deleted_flags()
    |> Map.put(:custom_fields, extract_custom_fields(original_map))
    |> Map.put(:original_object, original_map)
  end

  defp sync_owner_ids(%{owner_id: nil, user_id: user_id} = map) when not is_nil(user_id) do
    %{map | owner_id: user_id}
  end

  defp sync_owner_ids(%{owner_id: owner_id, user_id: nil} = map) when not is_nil(owner_id) do
    %{map | user_id: owner_id}
  end

  defp sync_owner_ids(map), do: map

  defp sync_deleted_flags(%{is_deleted: nil, deleted: deleted} = map) when is_boolean(deleted) do
    %{map | is_deleted: deleted}
  end

  defp sync_deleted_flags(%{is_deleted: is_deleted, deleted: nil} = map)
       when is_boolean(is_deleted) do
    %{map | deleted: is_deleted}
  end

  defp sync_deleted_flags(map), do: map
end
