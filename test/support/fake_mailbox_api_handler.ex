defmodule ExPipedrive.FakeMailboxApiHandler do
  @moduledoc false

  import Plug.Conn

  @thread_id 1
  @message_id 123

  @party %{
    "id" => 11,
    "name" => "Alice Sender",
    "latest_sent" => true,
    "email_address" => "alice@example.com",
    "message_time" => 1_710_000_000,
    "linked_person_id" => 101,
    "linked_person_name" => "Alice Sender",
    "mail_message_party_id" => 1001,
    "linked_organization_id" => 201
  }

  @thread %{
    "id" => @thread_id,
    "account_id" => "acc_987654",
    "user_id" => 42,
    "subject" => "Re: Contract details",
    "snippet" => "Thanks - please find the updated version attached...",
    "read_flag" => 1,
    "mail_tracking_status" => "enabled",
    "has_attachments_flag" => 1,
    "has_inline_attachments_flag" => 0,
    "has_real_attachments_flag" => 1,
    "deleted_flag" => 0,
    "synced_flag" => 1,
    "smart_bcc_flag" => 0,
    "mail_link_tracking_enabled_flag" => 1,
    "parties" => %{},
    "drafts_parties" => [],
    "folders" => ["inbox"],
    "version" => 1,
    "snippet_draft" => "",
    "snippet_sent" => "Sent: Please review the contract...",
    "message_count" => 5,
    "has_draft_flag" => 0,
    "has_sent_flag" => 1,
    "archived_flag" => 0,
    "shared_flag" => 0,
    "external_deleted_flag" => 0,
    "first_message_to_me_flag" => 1,
    "last_message_timestamp" => "2024-01-15 10:30:00",
    "first_message_timestamp" => "2024-01-10 09:00:00",
    "last_message_sent_timestamp" => "2024-01-15 10:30:00",
    "last_message_received_timestamp" => "2024-01-14 16:05:00",
    "add_time" => "2024-01-10 09:00:05",
    "update_time" => "2024-01-15 10:30:10",
    "deal_id" => 555,
    "deal_status" => "open",
    "lead_id" => "lead_abc123",
    "all_messages_sent_flag" => 0
  }

  @message %{
    "id" => @message_id,
    "account_id" => "acc_abc123",
    "user_id" => 42,
    "subject" => "Re: Contract details",
    "snippet" => "Thanks - please find the updated version attached...",
    "read_flag" => 1,
    "mail_tracking_status" => "unknown",
    "has_attachments_flag" => 0,
    "has_inline_attachments_flag" => 0,
    "has_real_attachments_flag" => 0,
    "deleted_flag" => 0,
    "synced_flag" => 1,
    "smart_bcc_flag" => 0,
    "mail_link_tracking_enabled_flag" => 0,
    "from" => [@party],
    "to" => [%{@party | "id" => 12, "name" => "Bob Recipient", "latest_sent" => false}],
    "cc" => [],
    "bcc" => [],
    "body_url" => "https://app.pipedrive.com/mailbox/message/#{@message_id}",
    "mail_thread_id" => @thread_id,
    "draft" => nil,
    "has_body_flag" => 1,
    "sent_flag" => 1,
    "sent_from_pipedrive_flag" => 0,
    "message_time" => "2024-01-15 10:30:00",
    "add_time" => "2024-01-15 10:30:05",
    "update_time" => "2024-01-15 10:30:10"
  }

  def handle_list_mail_threads(conn, params \\ %{}) do
    data =
      case Map.get(params, "folder", "inbox") do
        "inbox" -> [@thread]
        _ -> []
      end

    json(conn, 200, %{"success" => true, "data" => data})
  end

  def handle_get_mail_thread(conn, %{"id" => "1"}) do
    json(conn, 200, %{"success" => true, "data" => @thread})
  end

  def handle_get_mail_thread(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Mail thread not found"})
  end

  def handle_list_mail_thread_messages(conn, %{"id" => "1"}) do
    json(conn, 200, %{"success" => true, "data" => [@message]})
  end

  def handle_list_mail_thread_messages(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Mail thread not found"})
  end

  def handle_get_mail_message(conn, %{"id" => "123"}) do
    body =
      if conn.query_params["include_body"] == "1" do
        Map.put(@message, "body", "Hi there,\n\nThanks!")
      else
        @message
      end

    json(conn, 200, %{
      "success" => true,
      "statusCode" => 2000,
      "statusText" => "Success",
      "service" => "email-api",
      "data" => body
    })
  end

  def handle_get_mail_message(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Mail message not found"})
  end

  def handle_update_mail_thread(%{body_params: body, params: %{"id" => "1"}} = conn) do
    thread = Map.merge(@thread, body)
    json(conn, 200, %{"success" => true, "data" => thread})
  end

  def handle_update_mail_thread(%{params: %{"id" => "404"}} = conn) do
    json(conn, 404, %{"success" => false, "error" => "Mail thread not found"})
  end

  def handle_delete_mail_thread(conn, %{"id" => "1"}) do
    json(conn, 200, %{"success" => true, "data" => %{"id" => @thread_id}})
  end

  def handle_delete_mail_thread(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Mail thread not found"})
  end

  defp json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(status, Jason.encode!(body))
  end
end
