defmodule ExPipedrive.FakeCallLogApiHandler do
  @moduledoc false

  import Plug.Conn

  @call_log_id "CAd92b224eb4a39b5ad8fea92ff0e"

  @call_log %{
    "id" => @call_log_id,
    "activity_id" => 7007,
    "person_id" => 333_222_111,
    "org_id" => 123_456_789,
    "deal_id" => 553_229_734,
    "subject" => "Just call me maybe",
    "duration" => "0",
    "outcome" => "busy",
    "from_phone_number" => "+37277774841",
    "to_phone_number" => "+37249234343",
    "has_recording" => false,
    "start_time" => "2022-12-12T01:01:01.000Z",
    "end_time" => "2022-12-12T01:02:01.000Z",
    "user_id" => 777_707_777,
    "company_id" => 66_660_666,
    "note" => "A note for the call log"
  }

  def handle_list_call_logs(conn, params \\ %{}) do
    start = params |> Map.get("start", "0") |> String.to_integer()
    limit = params |> Map.get("limit", "50") |> String.to_integer()

    json(conn, 200, %{
      "success" => true,
      "data" => [@call_log],
      "additional_data" => %{
        "pagination" => %{
          "start" => start,
          "limit" => limit,
          "more_items_in_collection" => false
        }
      }
    })
  end

  def handle_get_call_log(conn, %{"id" => @call_log_id}) do
    json(conn, 200, %{"success" => true, "data" => @call_log})
  end

  def handle_get_call_log(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Call log not found"})
  end

  def handle_create_call_log(%{body_params: %{"to_phone_number" => _} = body} = conn) do
    call_log =
      @call_log
      |> Map.merge(body)
      |> Map.put("has_recording", false)

    json(conn, 201, %{"success" => true, "data" => call_log})
  end

  def handle_add_call_log_recording(%{params: %{"id" => @call_log_id}} = conn) do
    json(conn, 200, %{"success" => true})
  end

  def handle_add_call_log_recording(%{params: %{"id" => "404"}} = conn) do
    json(conn, 404, %{"success" => false, "error" => "Call log not found"})
  end

  def handle_delete_call_log(conn, %{"id" => @call_log_id}) do
    json(conn, 200, %{"success" => true})
  end

  def handle_delete_call_log(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Call log not found"})
  end

  defp json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(status, Jason.encode!(body))
  end
end
