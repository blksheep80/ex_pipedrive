defmodule ExPipedrive.Incoming.HandlerTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Plug.Test

  alias ExPipedrive.Incoming.Handler

  defmodule WebhookHandler do
    @behaviour ExPipedrive.Webhook.Handler

    @impl true
    def handle_event(event), do: send(self(), {:webhook_event, event})
  end

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

  test "POST /webhook delivers a normalized event to a handler module" do
    conn = post_webhook(handler_opts(handler: WebhookHandler))

    assert conn.status == 200

    assert_receive {:webhook_event,
                    %ExPipedrive.Webhook.Event{
                      name: "updated.deal",
                      current: %ExPipedrive.Deal{id: 3}
                    }}
  end

  test "POST /webhook returns 200 without on_event callback" do
    conn = post_webhook()

    assert conn.status == 200
  end

  test "POST /webhook can be mounted without basic authentication" do
    conn =
      :post
      |> conn("/webhook", Jason.encode!(@webhook_body))
      |> put_req_header("content-type", "application/json")
      |> Handler.call(Handler.init(on_event: fn _ -> :ok end))

    assert conn.status == 200
  end

  test "init/1 rejects an invalid basic authentication option" do
    assert_raise ArgumentError, ~r/:auth_fn/, fn ->
      Handler.init(auth_fn: :invalid)
    end
  end
end
