defmodule LineDrive.Note do
  @moduledoc """
  This module and enclosed structs represent a note in pipedrive.
  """

  use TypedStruct
  use LineDrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :content, String.t(), enforce: true
    field :active_flag, boolean()
    field :add_time, DateTime.t()
    field :update_time, DateTime.t()
    field :user_id, pos_integer()
    field :org_id, pos_integer()
    field :person_id, pos_integer()
    field :deal_id, pos_integer()
    field :lead_id, String.t()
    field :project_id, pos_integer()
    field :pinned_to_organization_flag, boolean(), default: false
    field :pinned_to_person_flag, boolean(), default: false
    field :pinned_to_deal_flag, boolean(), default: false
    field :pinned_to_lead_flag, boolean(), default: false
    field :pinned_to_project_flag, boolean(), default: false
    field :original_object, map()
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(%{} = note, opts) do
      Jason.Encode.value(
        Map.take(Map.from_struct(note), [
          :content,
          :org_id,
          :person_id,
          :deal_id,
          :lead_id,
          :pinned_to_organization_flag
        ]),
        opts
      )
    end

    def encode(note, opts), do: Jason.encode(note, opts)
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.put(:original_object, original)
  end
end
