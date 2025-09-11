defmodule LineDrive.Lead do
  @moduledoc """
  This module and enclosed structs represent a lead in pipedrive.
  """

  use TypedStruct
  use LineDrive.Structable

  alias LineDrive.LeadOrganization
  alias LineDrive.LeadPerson
  alias LineDrive.LeadValue

  typedstruct do
    field :id, String.t()
    field :title, String.t(), enforce: true
    field :owner_id, pos_integer()
    field :creator_id, pos_integer()
    field :label_ids, list(String.t())
    field :person_id, pos_integer()
    field :person, LeadPerson
    field :organization_id, pos_integer()
    field :organization, LeadOrganization
    field :source_name, String.t()
    field :origin, String.t()
    field :channel, String.t()
    field :channel_id, String.t()
    field :is_archived, boolean()
    field :was_seen, boolean()
    field :value, LeadValue
    field :expected_close_date, Date.t()
    field :next_activity_id, pos_integer()
    field :add_time, DateTime.t()
    field :update_time, DateTime.t()
    field :visible_to, String.t()
    field :cc_email, String.t()
    field :original_object, map()
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(%{} = lead, opts) do
      Jason.Encode.value(
        Map.take(Map.from_struct(lead), [
          :title,
          :person_id,
          :organization_id,
          :value,
          :expected_close_date
        ]),
        opts
      )
    end

    def encode(lead, opts), do: Jason.encode(lead, opts)
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:expected_close_date, nil, &parse_date/1)
    |> Map.update(:organization, nil, &safe_new_organization/1)
    |> Map.update(:person, nil, &safe_new_person/1)
    |> Map.update(:value, nil, &safe_new_value/1)
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.put(:original_object, original)
  end

  defp safe_new_organization(nil), do: nil
  defp safe_new_organization(data), do: LeadOrganization.new(data)

  defp safe_new_person(nil), do: nil
  defp safe_new_person(data), do: LeadPerson.new(data)

  defp safe_new_value(nil), do: nil
  defp safe_new_value(data), do: LeadValue.new(data)
end
