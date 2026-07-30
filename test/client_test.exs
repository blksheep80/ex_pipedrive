defmodule ExPipedrive.ClientTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Client

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

  describe "new/2" do
    test "builds a Tesla client with BaseUrl and query-param auth" do
      client = Client.new("token-123", "company.pipedrive.com")

      assert %Tesla.Client{} = client

      middleware_modules =
        Enum.map(client.pre, fn
          {module, _, _} -> module
          {module, _} -> module
          module when is_atom(module) -> module
        end)

      assert Tesla.Middleware.BaseUrl in middleware_modules
      assert Tesla.Middleware.JSON in middleware_modules
      assert Tesla.Middleware.Query in middleware_modules
      assert Tesla.Middleware.PathParams in middleware_modules
    end
  end

  describe "ExPipedrive.client/2 facade" do
    test "delegates to Client.new/2" do
      assert %Tesla.Client{} = ExPipedrive.client("token", "http://localhost:4006/")
    end
  end
end
