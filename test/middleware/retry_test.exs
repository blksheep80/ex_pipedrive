defmodule ExPipedrive.Middleware.RetryTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Client
  alias ExPipedrive.Request

  defmodule FlakyAdapter do
    @behaviour Tesla.Adapter

    @impl true
    def call(env, opts) do
      agent = Keyword.fetch!(opts, :agent)
      send(Keyword.fetch!(opts, :test_pid), {:tesla_request, env})

      n = Agent.get_and_update(agent, fn i -> {i, i + 1} end)

      case n do
        0 ->
          {:ok,
           %{
             env
             | status: 429,
               body: %{"success" => false, "error" => "rate limited"},
               headers: [{"retry-after", "0"}, {"x-ratelimit-remaining", "0"}]
           }}

        _ ->
          {:ok, %{env | status: 200, body: %{"success" => true, "data" => %{"ok" => true}}}}
      end
    end
  end

  defmodule Always429Adapter do
    @behaviour Tesla.Adapter

    @impl true
    def call(env, opts) do
      send(Keyword.fetch!(opts, :test_pid), :hit)

      {:ok,
       %{
         env
         | status: 429,
           body: %{"success" => false},
           headers: [{"retry-after", "0"}]
       }}
    end
  end

  test "retries 429 then succeeds, honoring Retry-After via sleep callback" do
    {:ok, agent} = Agent.start_link(fn -> 0 end)
    {:ok, sleeps} = Agent.start_link(fn -> [] end)

    client =
      Client.new("token", "http://example.test",
        telemetry: false,
        retry: [
          max_retries: 2,
          delay: 10,
          sleep: fn ms ->
            Agent.update(sleeps, &[ms | &1])
            :ok
          end
        ],
        adapter: {FlakyAdapter, [agent: agent, test_pid: self()]}
      )

    assert {:ok, %{status: 200}} = Request.get(client, "deals")
    assert_received {:tesla_request, _}
    assert_received {:tesla_request, _}

    assert [0] = Agent.get(sleeps, & &1)
  end

  test "exhausts retries and returns final 429" do
    {:ok, sleeps} = Agent.start_link(fn -> [] end)

    client =
      Client.new("token", "http://example.test",
        telemetry: false,
        retry: [
          max_retries: 2,
          sleep: fn ms ->
            Agent.update(sleeps, &[ms | &1])
            :ok
          end
        ],
        adapter: {Always429Adapter, [test_pid: self()]}
      )

    assert {:ok, %{status: 429}} = Request.get(client, "deals")
    assert_received :hit
    assert_received :hit
    assert_received :hit
    assert length(Agent.get(sleeps, & &1)) == 2
  end
end
