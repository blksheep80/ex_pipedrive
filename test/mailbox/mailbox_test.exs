defmodule ExPipedrive.MailboxTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.Mailbox
  alias ExPipedrive.MailMessage
  alias ExPipedrive.MailThread

  describe "list_threads/2" do
    test "lists mail threads in the inbox folder", %{client: client} do
      assert {:ok,
              [
                %MailThread{
                  id: 1,
                  subject: "Re: Contract details",
                  read_flag: true,
                  has_attachments_flag: true,
                  message_count: 5,
                  deal_id: 555,
                  lead_id: "lead_abc123",
                  add_time: %NaiveDateTime{},
                  folders: ["inbox"]
                }
              ]} = Mailbox.list_threads(client, folder: "inbox")
    end

    test "returns an empty list for other folders", %{client: client} do
      assert {:ok, []} = Mailbox.list_threads(client, folder: "sent")
    end

    test "defaults to the inbox folder", %{client: client} do
      assert {:ok, [%MailThread{id: 1}]} = Mailbox.list_threads(client)
    end
  end

  describe "get_thread/2" do
    test "fetches a mail thread by id", %{client: client} do
      assert {:ok,
              %MailThread{
                id: 1,
                subject: "Re: Contract details",
                archived_flag: false,
                shared_flag: false,
                deal_status: "open"
              }} = Mailbox.get_thread(client, 1)
    end

    test "maps missing mail threads to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Mailbox.get_thread(client, 404)
    end
  end

  describe "list_thread_messages/2" do
    test "lists mail messages inside a thread", %{client: client} do
      assert {:ok,
              [
                %MailMessage{
                  id: 123,
                  subject: "Re: Contract details",
                  mail_thread_id: 1,
                  has_body_flag: true,
                  sent_flag: true,
                  from: [%ExPipedrive.MailMessageParty{email_address: "alice@example.com"}],
                  to: [%ExPipedrive.MailMessageParty{name: "Bob Recipient"}]
                }
              ]} = Mailbox.list_thread_messages(client, 1)
    end

    test "maps missing mail threads to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Mailbox.list_thread_messages(client, 404)
    end
  end

  describe "get_message/3" do
    test "fetches a mail message by id", %{client: client} do
      assert {:ok, %MailMessage{id: 123, subject: "Re: Contract details", body: nil}} =
               Mailbox.get_message(client, 123)
    end

    test "includes the message body when requested", %{client: client} do
      assert {:ok, %MailMessage{id: 123, body: "Hi there,\n\nThanks!"}} =
               Mailbox.get_message(client, 123, include_body: 1)
    end

    test "maps missing mail messages to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Mailbox.get_message(client, 404)
    end
  end

  describe "update_thread/3" do
    test "updates a mail thread's associations and flags", %{client: client} do
      assert {:ok, %MailThread{id: 1, deal_id: 789, read_flag: true}} =
               Mailbox.update_thread(client, 1, %{deal_id: 789, read_flag: 1, ignored: "not sent"})
    end

    test "maps missing mail threads to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Mailbox.update_thread(client, 404, %{read_flag: 1})
    end
  end

  describe "delete_thread/2" do
    test "marks a mail thread as deleted", %{client: client} do
      assert {:ok, :ok} = Mailbox.delete_thread(client, 1)
    end

    test "maps missing mail threads to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Mailbox.delete_thread(client, 404)
    end
  end
end
