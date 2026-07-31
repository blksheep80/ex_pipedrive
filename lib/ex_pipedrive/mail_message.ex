defmodule ExPipedrive.MailMessage do
  @moduledoc """
  A single email inside a Pipedrive mail thread.

  Decoded from `GET /api/v1/mailbox/mailMessages/:id` and
  `GET /api/v1/mailbox/mailThreads/:id/mailMessages` responses. `:from`,
  `:to`, `:cc`, and `:bcc` are lists of `ExPipedrive.MailMessageParty`.
  `:body` is only present when the request opted in with `include_body: 1`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  alias ExPipedrive.MailMessageParty

  typedstruct do
    field :id, pos_integer()
    field :account_id, String.t()
    field :user_id, pos_integer()
    field :subject, String.t()
    field :snippet, String.t()
    field :body, String.t()
    field :read_flag, boolean()
    field :mail_tracking_status, String.t()
    field :has_attachments_flag, boolean()
    field :has_inline_attachments_flag, boolean()
    field :has_real_attachments_flag, boolean()
    field :deleted_flag, boolean()
    field :synced_flag, boolean()
    field :smart_bcc_flag, boolean()
    field :mail_link_tracking_enabled_flag, boolean()
    field :from, list(MailMessageParty.t()), default: []
    field :to, list(MailMessageParty.t()), default: []
    field :cc, list(MailMessageParty.t()), default: []
    field :bcc, list(MailMessageParty.t()), default: []
    field :body_url, String.t()
    field :mail_thread_id, pos_integer()
    field :draft, String.t()
    field :has_body_flag, boolean()
    field :sent_flag, boolean()
    field :sent_from_pipedrive_flag, boolean()
    field :message_time, DateTime.t() | NaiveDateTime.t()
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :update_time, DateTime.t() | NaiveDateTime.t()
    field :original_object, map()
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:user_id, nil, &normalize_id/1)
    |> Map.update(:mail_thread_id, nil, &normalize_id/1)
    |> Map.update(:read_flag, nil, &flag/1)
    |> Map.update(:has_attachments_flag, nil, &flag/1)
    |> Map.update(:has_inline_attachments_flag, nil, &flag/1)
    |> Map.update(:has_real_attachments_flag, nil, &flag/1)
    |> Map.update(:deleted_flag, nil, &flag/1)
    |> Map.update(:synced_flag, nil, &flag/1)
    |> Map.update(:smart_bcc_flag, nil, &flag/1)
    |> Map.update(:mail_link_tracking_enabled_flag, nil, &flag/1)
    |> Map.update(:has_body_flag, nil, &flag/1)
    |> Map.update(:sent_flag, nil, &flag/1)
    |> Map.update(:sent_from_pipedrive_flag, nil, &flag/1)
    |> Map.update(:message_time, nil, &parse_datetime/1)
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.update(:from, [], &parse_parties/1)
    |> Map.update(:to, [], &parse_parties/1)
    |> Map.update(:cc, [], &parse_parties/1)
    |> Map.update(:bcc, [], &parse_parties/1)
    |> Map.put(:original_object, original)
  end

  defp parse_parties(parties) when is_list(parties),
    do: Enum.map(parties, &MailMessageParty.new/1)

  defp parse_parties(_), do: []

  defp flag(nil), do: nil
  defp flag(true), do: true
  defp flag(false), do: false
  defp flag(1), do: true
  defp flag(0), do: false
  defp flag("1"), do: true
  defp flag("0"), do: false
  defp flag(other), do: other
end
