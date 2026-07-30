defmodule ExPipedrive.Incoming.HandlerTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Plug.Test

  alias ExPipedrive.Incoming.Handler

  @webhook_body %{
    "current" => %{
      "id" => 3,
      "title" => "Mecklem, LLC deal",
      "value" => 50_010,
      "weighted_value" => 50_010,
      "status" => "open",
      "pipeline_id" => 2,
      "stage_id" => 7
    },
    "event" => "updated.deal",
    "meta" => %{"host" => "launchscout-sandbox.pipedrive.com"},
    "previous" => %{
      "id" => 3,
      "title" => "Mecklem, LLC deal",
      "value" => 50_011,
      "weighted_value" => 50_011,
      "status" => "open",
      "pipeline_id" => 2,
      "stage_id" => 7
    }
  }

  defp handler_opts(extra \\ []) do
    [auth_fn: fn -> [username: "user", password: "secret"] end] ++ extra
  end

  defp post_webhook(opts \\ handler_opts()) do
    auth = Base.encode64("user:secret")

    :post
    |> conn("/webhook", Jason.encode!(@webhook_body))
    |> put_req_header("content-type", "application/json")
    |> put_req_header("authorization", "Basic #{auth}")
    |> Handler.call(Handler.init(opts))
  end

  test "POST /webhook returns 200 and invokes on_event callback" do
    test_pid = self()

    on_event = fn {:updated_deal, _payload} -> send(test_pid, :event_received) end

    conn = post_webhook(handler_opts(on_event: on_event))

    assert conn.status == 200
    assert_receive :event_received
  end

  test "POST /webhook returns 200 without on_event callback" do
    conn = post_webhook()

    assert conn.status == 200
  end

  test "init/1 requires auth_fn" do
    assert_raise ArgumentError, ~r/:auth_fn/, fn ->
      Handler.init(on_event: fn _ -> :ok end)
    end
  end
end
