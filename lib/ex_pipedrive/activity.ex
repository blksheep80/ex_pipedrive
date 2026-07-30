defmodule ExPipedrive.Activity do
  @moduledoc """
  Activity entity decoded from Pipedrive API v1 or v2 responses.

  ID references are normalized to integers. V2 nested `location` objects and
  `busy`/`owner_id` aliases are synced onto legacy field names; the raw payload
  remains on `original_object`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  alias ExPipedrive.ActivityParticipant
  alias ExPipedrive.ActivityType

  typedstruct do
    field :id, pos_integer()
    field :company_id, pos_integer()
    field :user_id, pos_integer()
    field :owner_id, pos_integer()
    field :done, boolean()
    field :type, ActivityType.key_string(), enforce: true
    field :conference_meeting_client, String.t()
    field :conference_meeting_url, String.t()
    field :conference_meeting_id, String.t()
    field :due_date, Date.t()
    field :due_time, String.t()
    field :duration, String.t()
    field :busy_flag, boolean()
    field :busy, boolean()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :marked_as_done_time, DateTime.t() | NaiveDateTime.t()
    field :subject, String.t(), enforce: true
    field :public_description, String.t()
    field :location, String.t()
    field :org_id, pos_integer()
    field :person_id, pos_integer()
    field :deal_id, pos_integer()
    field :lead_id, String.t()
    field :project_id, pos_integer()
    field :active_flag, boolean()
    field :is_deleted, boolean()
    field :update_time, DateTime.t() | NaiveDateTime.t()
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
    field :attendees, list()
    field :priority, integer()

    # Fields maintained for compatibility with legacy API endpoints
    # These fields are used in the /activities endpoint but not in /activities/collection
    field :note, String.t()
    field :org_name, String.t()
    field :reference_type, String.t()
    field :reference_id, pos_integer()
    field :notification_language_id, pos_integer()
    field :calendar_sync_include_context, boolean()
    field :last_notification_time, DateTime.t() | NaiveDateTime.t()
    field :last_notification_user_id, pos_integer()
    field :custom_fields, map(), default: %{}
    field :original_object, map()
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(%{id: nil} = activity, opts) do
      activity
      |> Map.from_struct()
      |> Map.delete(:id)
      |> Map.delete(:org_name)
      |> Map.delete(:original_object)
      |> Map.delete(:custom_fields)
      |> Jason.Encode.value(opts)
    end

    def encode(activity, opts), do: Jason.encode(activity, opts)
  end

  def handle_transform(map, original_map, opts \\ []) do
    _version = Keyword.get(opts, :version, :auto)

    map
    |> Map.update(:due_date, nil, &parse_date/1)
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.update(:marked_as_done_time, nil, &parse_datetime/1)
    |> Map.update(:last_notification_time, nil, &parse_datetime/1)
    |> Map.update(:owner_id, nil, &normalize_id/1)
    |> Map.update(:user_id, nil, &normalize_id/1)
    |> Map.update(:org_id, nil, &normalize_id/1)
    |> Map.update(:person_id, nil, &normalize_id/1)
    |> Map.update(:deal_id, nil, &normalize_id/1)
    |> Map.update(:project_id, nil, &normalize_id/1)
    |> sync_owner_ids()
    |> sync_busy_flags()
    |> sync_location(original_map)
    |> sync_participants(original_map)
    |> sync_deleted_flag()
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

  defp sync_busy_flags(%{busy: nil, busy_flag: busy_flag} = map) when is_boolean(busy_flag) do
    %{map | busy: busy_flag}
  end

  defp sync_busy_flags(%{busy: busy, busy_flag: nil} = map) when is_boolean(busy) do
    %{map | busy_flag: busy}
  end

  defp sync_busy_flags(map), do: map

  defp sync_location(map, original_map) do
    location =
      case Map.get(original_map, "location") || Map.get(original_map, :location) || map.location do
        %{"value" => value} -> value
        %{value: value} -> value
        value when is_binary(value) -> value
        _ -> map.location
      end

    %{map | location: location}
  end

  defp sync_participants(map, original_map) do
    participants =
      case Map.get(original_map, "participants") || Map.get(original_map, :participants) ||
             map.participants do
        list when is_list(list) -> Enum.map(list, &ActivityParticipant.new/1)
        _ -> map.participants
      end

    %{map | participants: participants}
  end

  defp sync_deleted_flag(%{is_deleted: nil, active_flag: true} = map),
    do: %{map | is_deleted: false}

  defp sync_deleted_flag(%{is_deleted: nil, active_flag: false} = map),
    do: %{map | is_deleted: true}

  defp sync_deleted_flag(map), do: map
end
