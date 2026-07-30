defmodule ExPipedrive.RequestTest do
  use ExUnit.Case, async: true
  doctest ExPipedrive.Request

  alias ExPipedrive.Request

  describe "path/2" do
    test "defaults to v2" do
      assert Request.path("deals") == "/api/v2/deals"
      assert Request.path("persons/:id") == "/api/v2/persons/:id"
      assert Request.path(:deals) == "/api/v2/deals"
    end

    test "supports explicit v1 fallback" do
      assert Request.path("deals", api_version: :v1) == "/api/v1/deals"
      assert Request.path("dealFields", api_version: :v1) == "/api/v1/dealFields"

      assert Request.path("activities/collection", api_version: :v1) ==
               "/api/v1/activities/collection"
    end

    test "strips a leading slash from the resource segment" do
      assert Request.path("/deals") == "/api/v2/deals"
    end

    test "rejects unsupported versions" do
      assert_raise ArgumentError, ~r/unsupported api_version/, fn ->
        Request.path("deals", api_version: :v3)
      end
    end
  end

  describe "HTTP helpers" do
    defmodule CaptureAdapter do
      @behaviour Tesla.Adapter

      @impl true
      def call(env, _opts) do
        send(env.opts[:test_pid], {:tesla_request, env})
        {:ok, %{env | status: 200, body: %{"success" => true, "data" => []}}}
      end
    end

    setup do
      client =
        Tesla.client(
          [
            {Tesla.Middleware.BaseUrl, "http://example.test"},
            Tesla.Middleware.PathParams,
            {Tesla.Middleware.Opts, [test_pid: self()]}
          ],
          CaptureAdapter
        )

      {:ok, client: client}
    end

    test "get defaults to v2 path", %{client: client} do
      assert {:ok, _} = Request.get(client, "deals")
      assert_received {:tesla_request, %Tesla.Env{url: "http://example.test/api/v2/deals"}}
    end

    test "get supports v1 fallback without duplicating HTTP logic", %{client: client} do
      assert {:ok, _} = Request.get(client, "deals", api_version: :v1)
      assert_received {:tesla_request, %Tesla.Env{url: "http://example.test/api/v1/deals"}}
    end

    test "post/put/patch/delete route through the same versioned path builder", %{client: client} do
      assert {:ok, _} = Request.post(client, "persons", %{name: "Ada"}, api_version: :v1)
      assert_received {:tesla_request, %Tesla.Env{method: :post, url: url}}
      assert String.ends_with?(url, "/api/v1/persons")

      assert {:ok, _} =
               Request.put(client, "organizations/:id", %{},
                 api_version: :v1,
                 opts: [path_params: [id: 5]]
               )

      assert_received {:tesla_request, %Tesla.Env{method: :put, url: put_url}}
      assert String.ends_with?(put_url, "/api/v1/organizations/5")

      assert {:ok, _} = Request.patch(client, "deals/:id", %{}, opts: [path_params: [id: 9]])
      assert_received {:tesla_request, %Tesla.Env{method: :patch, url: patch_url}}
      assert String.ends_with?(patch_url, "/api/v2/deals/9")

      assert {:ok, _} =
               Request.delete(client, "leads/:id",
                 api_version: :v1,
                 opts: [path_params: [id: "abc"]]
               )

      assert_received {:tesla_request, %Tesla.Env{method: :delete, url: delete_url}}
      assert String.ends_with?(delete_url, "/api/v1/leads/abc")
    end
  end
end
