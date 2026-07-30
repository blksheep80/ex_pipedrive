defmodule LineDrive.Deal do
  @moduledoc """
  This module and enclosed struct represent a deal in pipedrive.
  """

  use TypedStruct
  use LineDrive.Structable

  alias LineDrive.Organization
  alias LineDrive.User

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
    field :add_time, DateTime.t()
    field :update_time, DateTime.t()
    field :stage_change_time, DateTime.t()
    field :active, boolean()
    field :deleted, boolean()
    field :probability, non_neg_integer()
    field :next_activity_date, Date.t()
    field :next_activity_time, Time.t()
    field :next_activity_id, non_neg_integer()
    field :last_activity_id, non_neg_integer()
    field :last_activity_date, Date.t()
    field :lost_reason, String.t()
    field :visible_to, non_neg_integer()
    field :close_time, DateTime.t()
    field :won_time, DateTime.t()
    field :first_won_time, DateTime.t()
    field :lost_time, DateTime.t()
    field :products_count, non_neg_integer()
    field :files_count, non_neg_integer()
    field :notes_count, non_neg_integer()
    field :followers_count, non_neg_integer()
    field :email_messages_count, non_neg_integer()
    field :activities_count, non_neg_integer()
    field :done_activities_count, non_neg_integer()
    field :undone_activities_count, non_neg_integer()
    field :participants_count, non_neg_integer()
    field :last_incoming_mail_time, DateTime.t()
    field :last_outgoing_mail_time, DateTime.t()
    field :label, String.t()
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
    field :creator_user_id, User.t()
    field :user_id, User.t()
    field :org_id, Organization.t()
    field :original_object, %{}
  end

  def handle_transform(map, original_map) do
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
    |> Map.update(:creator_user_id, nil, &User.new/1)
    |> Map.update(:user_id, nil, &User.new/1)
    |> Map.update(:org_id, nil, &Organization.new/1)
    |> Map.update(:visible_to, nil, &parse_integer/1)
    |> Map.put(:original_object, original_map)
  end
end
