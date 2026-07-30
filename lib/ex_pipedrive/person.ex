defmodule LineDrive.Person do
  @moduledoc """
  This module and enclosed struct represent a person in pipedrive.
  """

  use TypedStruct
  use LineDrive.Structable

  alias LineDrive.Organization

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
    field :update_time, NaiveDateTime.t()
    field :delete_time, NaiveDateTime.t()
    field :add_time, NaiveDateTime.t()
    field :visible_to, String.t()
    field :next_activity_date, Date.t()
    field :next_activity_time, Time.t()
    field :next_activity_id, pos_integer()
    field :last_activity_id, pos_integer()
    field :last_activity_date, Date.t()
    field :last_incoming_mail_time, NaiveDateTime.t()
    field :last_outgoing_mail_time, NaiveDateTime.t()
    field :label, non_neg_integer()
    field :owner_name, String.t()

    field :original_object, %{}
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
    |> then(&struct(__MODULE__, &1))
  end

  def handle_transform(map, original_map) do
    map
    |> Map.update(:next_activity_date, nil, &parse_date/1)
    |> Map.update(:next_activity_time, nil, &parse_time/1)
    |> Map.update(:last_activity_date, nil, &parse_date/1)
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.update(:delete_time, nil, &parse_datetime/1)
    |> Map.update(:last_incoming_mail_time, nil, &parse_datetime/1)
    |> Map.update(:last_outgoing_mail_time, nil, &parse_datetime/1)
    |> Map.update(:org_id, nil, &get_nested_value(&1, "value"))
    |> Map.update(:owner_id, nil, &get_nested_value(&1, "id"))
    |> Map.put(:original_object, original_map)
  end
end
