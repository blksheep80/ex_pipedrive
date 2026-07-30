defmodule ExPipedrive.ClientTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Client
  alias ExPipedrive.Request

  describe "base_url/1" do
    test "adds https scheme to bare api_domain hosts" do
      assert Client.base_url("company.pipedrive.com") == "https://company.pipedrive.com"
    end

    test "preserves existing http(s) schemes" do
      assert Client.base_url("https://company.pipedrive.com") == "https://company.pipedrive.com"
      assert Client.base_url("http://localhost:4006/") == "http://localhost:4006"
    end

    test "trims whitespace and trailing slashes" do
      assert Client.base_url("  company.pipedrive.com/  ") == "https://company.pipedrive.com"
    end
  end

  describe "new/2 header auth (default)" do
    defmodule CaptureAdapter do
      @behaviour Tesla.Adapter

      @impl true
      def call(env, opts) do
        send(Keyword.fetch!(opts, :test_pid), {:tesla_request, env})
        {:ok, %{env | status: 200, body: %{"success" => true, "data" => []}}}
      end
    end

    defmodule Passthrough do
      @behaviour Tesla.Middleware

      @impl true
      def call(env, next, _opts), do: Tesla.run(env, next)
    end

    defp capture_client(api_token, opts \\ []) do
      Client.new(
        api_token,
        "http://example.test",
        Keyword.merge(opts, adapter: {CaptureAdapter, [test_pid: self()]})
      )
    end

    test "builds a Tesla client with BaseUrl and x-api-token header middleware" do
      client = Client.new("token-123", "company.pipedrive.com")

      assert %Tesla.Client{} = client

      middleware_modules =
        Enum.map(client.pre, fn
          {module, _, _} -> module
          {module, _} -> module
          module when is_atom(module) -> module
        end)

      assert ExPipedrive.Middleware.Telemetry in middleware_modules
      assert ExPipedrive.Middleware.Retry in middleware_modules
      assert Tesla.Middleware.BaseUrl in middleware_modules
      assert Tesla.Middleware.JSON in middleware_modules
      assert Tesla.Middleware.Headers in middleware_modules
      assert Tesla.Middleware.PathParams in middleware_modules
      refute Tesla.Middleware.Query in middleware_modules
    end

    test "injects consumer middleware and can disable retry/telemetry" do
      client =
        Client.new("token", "company.pipedrive.com",
          retry: false,
          telemetry: false,
          middleware: [{Passthrough, []}]
        )

      middleware_modules =
        Enum.map(client.pre, fn
          {module, _, _} -> module
          {module, _} -> module
          module when is_atom(module) -> module
        end)

      refute ExPipedrive.Middleware.Retry in middleware_modules
      refute ExPipedrive.Middleware.Telemetry in middleware_modules
      assert Passthrough in middleware_modules
    end

    test "sends x-api-token header and does not inject api_token query param" do
      client = capture_client("secret-token")

      assert {:ok, _} = Request.get(client, "deals")

      assert_received {:tesla_request, %Tesla.Env{} = env}
      assert Tesla.get_header(env, "x-api-token") == "secret-token"
      refute Keyword.has_key?(env.query || [], :api_token)
      refute String.contains?(env.url, "api_token=")
    end

    test "v2 paths use header auth by default" do
      client = capture_client("v2-token")

      assert {:ok, _} = Request.get(client, "deals")
      assert_received {:tesla_request, %Tesla.Env{url: url} = env}
      assert String.contains?(url, "/api/v2/deals")
      assert Tesla.get_header(env, "x-api-token") == "v2-token"
    end

    test "legacy query auth is isolated behind auth: :query" do
      client = capture_client("legacy-token", auth: :query)

      assert {:ok, _} = Request.get(client, "deals", api_version: :v1)

      assert_received {:tesla_request, %Tesla.Env{} = env}
      assert is_nil(Tesla.get_header(env, "x-api-token"))
      assert Keyword.get(env.query, :api_token) == "legacy-token"
    end

    test "rejects unsupported auth modes" do
      assert_raise ArgumentError, ~r/unsupported auth/, fn ->
        Client.new("token", "company.pipedrive.com", auth: :basic)
      end
    end
  end

  describe "ExPipedrive.client/2 facade" do
    test "delegates to Client.new/2 with header auth" do
      client = ExPipedrive.client("token", "http://localhost:4006/")
      assert %Tesla.Client{} = client

      middleware_modules =
        Enum.map(client.pre, fn
          {module, _, _} -> module
          {module, _} -> module
          module when is_atom(module) -> module
        end)

      assert Tesla.Middleware.Headers in middleware_modules
      refute Tesla.Middleware.Query in middleware_modules
    end
  end
end
