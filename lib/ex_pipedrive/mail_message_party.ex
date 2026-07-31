defmodule ExPipedrive.MailMessageParty do
  @moduledoc """
  A single sender/recipient entry on a `ExPipedrive.MailMessage`
  (`:from`, `:to`, `:cc`, or `:bcc`).
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :name, String.t()
    field :latest_sent, boolean()
    field :email_address, String.t()
    field :message_time, integer() | String.t()
    field :linked_person_id, pos_integer()
    field :linked_person_name, String.t()
    field :mail_message_party_id, pos_integer()
    field :linked_organization_id, pos_integer()
  end

  def handle_transform(map, _original) do
    map
    |> Map.update(:linked_person_id, nil, &normalize_id/1)
    |> Map.update(:linked_organization_id, nil, &normalize_id/1)
  end
end
