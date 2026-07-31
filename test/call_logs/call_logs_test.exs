defmodule ExPipedrive.CallLogsTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.CallLog
  alias ExPipedrive.CallLogs
  alias ExPipedrive.Error
  alias ExPipedrive.PagedResult

  @call_log_id "CAd92b224eb4a39b5ad8fea92ff0e"

  describe "list/2" do
    test "lists API v1 call logs", %{client: client} do
      assert {:ok,
              %PagedResult{
                data: [
                  %CallLog{
                    id: @call_log_id,
                    outcome: "busy",
                    to_phone_number: "+37249234343",
                    deal_id: 553_229_734,
                    start_time: %DateTime{},
                    end_time: %DateTime{}
                  }
                ]
              }} = CallLogs.list(client)
    end
  end

  describe "get/2" do
    test "fetches a call log by id", %{client: client} do
      assert {:ok, %CallLog{id: @call_log_id, outcome: "busy", note: "A note for the call log"}} =
               CallLogs.get(client, @call_log_id)
    end

    test "maps missing call logs to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = CallLogs.get(client, "404")
    end
  end

  describe "create/2" do
    test "creates a call log through POST /api/v1/callLogs", %{client: client} do
      assert {:ok,
              %CallLog{
                to_phone_number: "+15551234567",
                outcome: "connected",
                has_recording: false
              }} =
               CallLogs.create(client, %{
                 to_phone_number: "+15551234567",
                 outcome: "connected",
                 start_time: "2023-01-01 10:00:00",
                 end_time: "2023-01-01 10:05:00",
                 ignored: "not sent"
               })
    end
  end

  describe "add_recording/4" do
    test "attaches an audio recording to a call log", %{client: client} do
      assert {:ok, :ok} = CallLogs.add_recording(client, @call_log_id, "RIFF...", "call.wav")
    end

    test "maps missing call logs to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} =
               CallLogs.add_recording(client, "404", "RIFF...", "call.wav")
    end
  end

  describe "delete/2" do
    test "deletes a call log through DELETE /api/v1/callLogs/:id", %{client: client} do
      assert {:ok, :ok} = CallLogs.delete(client, @call_log_id)
    end

    test "maps missing call logs to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = CallLogs.delete(client, "404")
    end
  end
end
