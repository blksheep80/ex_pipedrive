defmodule LineDrive.Activity do
  @moduledoc """
  This module and enclosed struct represent a activity in pipedrive.
  """

  use TypedStruct
  use LineDrive.Structable

  alias LineDrive.ActivityParticipant
  alias LineDrive.ActivityType

  typedstruct do
    field :id, pos_integer()
    field :company_id, pos_integer()
    field :user_id, pos_integer()
    field :done, boolean()
    field :type, ActivityType.key_string(), enforce: true
    field :conference_meeting_client, String.t()
    field :conference_meeting_url, String.t()
    field :conference_meeting_id, String.t()
    field :due_date, Date.t()
    field :due_time, String.t()
    field :duration, String.t()
    field :busy_flag, boolean()
    field :add_time, NaiveDateTime.t()
    field :marked_as_done_time, NaiveDateTime.t()
    field :subject, String.t(), enforce: true
    field :public_description, String.t()
    field :location, String.t()
    field :org_id, pos_integer()
    field :person_id, pos_integer()
    field :deal_id, pos_integer()
    field :lead_id, String.t()
    field :project_id, pos_integer()
    field :active_flag, boolean()
    field :update_time, NaiveDateTime.t()
    field :update_user_id, pos_integer()
    field :source_timezone, String.t()
    field :location_subpremise, String.t()
    field :location_street_number, String.t()
    field :location_route, String.t()
    field :location_sublocality, String.t()
    field :location_locality, String.t()
    field :location_admin_area_level_1, String.t()
    field :location_admin_area_level_2, String.t()
    field :location_country, String.t()
    field :location_postal_code, String.t()
    field :location_formatted_address, String.t()
    field :participants, list(ActivityParticipant.t())

    # Fields maintained for compatibility with legacy API endpoints
    # These fields are used in the /activities endpoint but not in /activities/collection
    field :note, String.t()
    field :org_name, String.t()
    field :reference_type, String.t()
    field :reference_id, pos_integer()
    field :notification_language_id, pos_integer()
    field :calendar_sync_include_context, boolean()
    field :last_notification_time, NaiveDateTime.t()
    field :last_notification_user_id, pos_integer()
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(%{id: nil} = activity, opts) do
      activity
      |> Map.from_struct()
      |> Map.delete(:id)
      |> Map.delete(:org_name)
      |> Jason.Encode.value(opts)
    end

    def encode(activity, opts), do: Jason.encode(activity, opts)
  end

  def handle_transform(map, _) do
    map
    |> Map.update(:due_date, nil, &parse_date/1)
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.update(:marked_as_done_time, nil, &parse_datetime/1)
    |> Map.update(:last_notification_time, nil, &parse_datetime/1)
  end
end
