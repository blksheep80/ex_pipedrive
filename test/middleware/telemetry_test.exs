defmodule ExPipedrive.Middleware.TelemetryTest do
  use ExUnit.Case, async: false

  alias ExPipedrive.Client
  alias ExPipedrive.Request

  defmodule OkAdapter do
    @behaviour Tesla.Adapter

    @impl true
    def call(env, _opts) do
      {:ok,
       %{
         env
         | status: 200,
           body: %{"success" => true, "data" => []},
           headers: [{"x-ratelimit-remaining", "9"}, {"x-ratelimit-limit", "10"}]
       }}
    end
  end

  setup do
    handler_id = "ex-pipedrive-telemetry-test-#{System.unique_integer([:positive])}"
    parent = self()

    :telemetry.attach_many(
      handler_id,
      [
        [:ex_pipedrive, :request, :start],
        [:ex_pipedrive, :request, :stop]
      ],
      fn event, measurements, meta, _config ->
        send(parent, {:telemetry, event, measurements, meta})
      end,
      nil
    )

    on_exit(fn -> :telemetry.detach(handler_id) end)
    :ok
  end

  test "emits start and stop with rate_limit metadata" do
    client =
      Client.new("token", "http://example.test",
        retry: false,
        adapter: OkAdapter
      )

    assert {:ok, _} = Request.get(client, "deals")

    assert_receive {:telemetry, [:ex_pipedrive, :request, :start], %{system_time: _},
                    %{env: %Tesla.Env{}}}

    assert_receive {:telemetry, [:ex_pipedrive, :request, :stop], %{duration: duration}, meta}
    assert is_integer(duration)
    assert meta.rate_limit.limit == 10
    assert meta.rate_limit.remaining == 9
    assert meta.retry_count == 0
  end
end
