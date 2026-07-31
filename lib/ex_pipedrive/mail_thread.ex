defmodule ExPipedrive.MailThread do
  @moduledoc """
  A Pipedrive mailbox thread (a group of related mail messages).

  Decoded from `GET /api/v1/mailbox/mailThreads`,
  `GET /api/v1/mailbox/mailThreads/:id`, and
  `PUT /api/v1/mailbox/mailThreads/:id` responses.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :account_id, String.t()
    field :user_id, pos_integer()
    field :subject, String.t()
    field :snippet, String.t()
    field :read_flag, boolean()
    field :mail_tracking_status, String.t()
    field :has_attachments_flag, boolean()
    field :has_inline_attachments_flag, boolean()
    field :has_real_attachments_flag, boolean()
    field :deleted_flag, boolean()
    field :synced_flag, boolean()
    field :smart_bcc_flag, boolean()
    field :mail_link_tracking_enabled_flag, boolean()
    field :parties, map()
    field :drafts_parties, list()
    field :folders, list(String.t()), default: []
    field :version, integer()
    field :snippet_draft, String.t()
    field :snippet_sent, String.t()
    field :message_count, integer()
    field :has_draft_flag, boolean()
    field :has_sent_flag, boolean()
    field :archived_flag, boolean()
    field :shared_flag, boolean()
    field :external_deleted_flag, boolean()
    field :first_message_to_me_flag, boolean()
    field :last_message_timestamp, DateTime.t() | NaiveDateTime.t()
    field :first_message_timestamp, DateTime.t() | NaiveDateTime.t()
    field :last_message_sent_timestamp, DateTime.t() | NaiveDateTime.t()
    field :last_message_received_timestamp, DateTime.t() | NaiveDateTime.t()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :update_time, DateTime.t() | NaiveDateTime.t()
    field :deal_id, pos_integer()
    field :deal_status, String.t()
    field :lead_id, String.t()
    field :all_messages_sent_flag, boolean()
    field :original_object, map()
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:user_id, nil, &normalize_id/1)
    |> Map.update(:deal_id, nil, &normalize_id/1)
    |> Map.update(:read_flag, nil, &flag/1)
    |> Map.update(:has_attachments_flag, nil, &flag/1)
    |> Map.update(:has_inline_attachments_flag, nil, &flag/1)
    |> Map.update(:has_real_attachments_flag, nil, &flag/1)
    |> Map.update(:deleted_flag, nil, &flag/1)
    |> Map.update(:synced_flag, nil, &flag/1)
    |> Map.update(:smart_bcc_flag, nil, &flag/1)
    |> Map.update(:mail_link_tracking_enabled_flag, nil, &flag/1)
    |> Map.update(:has_draft_flag, nil, &flag/1)
    |> Map.update(:has_sent_flag, nil, &flag/1)
    |> Map.update(:archived_flag, nil, &flag/1)
    |> Map.update(:shared_flag, nil, &flag/1)
    |> Map.update(:external_deleted_flag, nil, &flag/1)
    |> Map.update(:first_message_to_me_flag, nil, &flag/1)
    |> Map.update(:all_messages_sent_flag, nil, &flag/1)
    |> Map.update(:last_message_timestamp, nil, &parse_datetime/1)
    |> Map.update(:first_message_timestamp, nil, &parse_datetime/1)
    |> Map.update(:last_message_sent_timestamp, nil, &parse_datetime/1)
    |> Map.update(:last_message_received_timestamp, nil, &parse_datetime/1)
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.put(:original_object, original)
  end

  defp flag(nil), do: nil
  defp flag(true), do: true
  defp flag(false), do: false
  defp flag(1), do: true
  defp flag(0), do: false
  defp flag("1"), do: true
  defp flag("0"), do: false
  defp flag(other), do: other
end
