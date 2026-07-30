defmodule ExPipedrive.RawTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Client
  alias ExPipedrive.Error
  alias ExPipedrive.Raw

  defmodule CaptureAdapter do
    @behaviour Tesla.Adapter

    @impl true
    def call(env, opts) do
      send(Keyword.fetch!(opts, :test_pid), {:tesla_request, env})

      case Keyword.get(opts, :response) do
        {:error, reason} ->
          {:error, reason}

        %{} = response ->
          {:ok,
           %{
             env
             | status: Map.get(response, :status, 200),
               body: Map.get(response, :body, %{"success" => true, "data" => %{}}),
               headers: Map.get(response, :headers, [])
           }}

        nil ->
          {:ok, %{env | status: 200, body: %{"success" => true, "data" => %{"ok" => true}}}}
      end
    end
  end

  defp client(response \\ nil) do
    Client.new("token", "http://example.test",
      adapter: {CaptureAdapter, [test_pid: self(), response: response]}
    )
  end

  describe "request/4 path resolution" do
    test "defaults resource segments to v2" do
      assert {:ok, _} = Raw.request(client(), :get, "dealFields")
      assert_received {:tesla_request, %Tesla.Env{url: url}}
      assert String.ends_with?(url, "/api/v2/dealFields")
    end

    test "supports explicit v1 resource segments" do
      assert {:ok, _} = Raw.request(client(), :get, "dealFields", api_version: :v1)
      assert_received {:tesla_request, %Tesla.Env{url: url}}
      assert String.ends_with?(url, "/api/v1/dealFields")
    end

    test "accepts absolute v1 and v2 paths" do
      assert {:ok, _} = Raw.request(client(), :get, "/api/v1/dealFields")
      assert_received {:tesla_request, %Tesla.Env{url: v1_url}}
      assert String.ends_with?(v1_url, "/api/v1/dealFields")

      assert {:ok, _} = Raw.request(client(), :get, "/api/v2/itemSearch", query: [term: "x"])
      assert_received {:tesla_request, %Tesla.Env{url: v2_url, query: query}}
      assert String.ends_with?(v2_url, "/api/v2/itemSearch")
      assert Keyword.get(query, :term) == "x"
    end

    test "absolute paths ignore api_version" do
      assert {:ok, _} =
               Raw.request(client(), :get, "/api/v1/notes", api_version: :v2)

      assert_received {:tesla_request, %Tesla.Env{url: url}}
      assert String.ends_with?(url, "/api/v1/notes")
    end
  end

  describe "request/4 methods and pass-through" do
    test "GET passes query and headers" do
      assert {:ok, body} =
               Raw.request(client(), :get, "persons",
                 query: [limit: 10],
                 headers: [{"x-custom", "1"}]
               )

      assert body["data"]["ok"] == true
      assert_received {:tesla_request, %Tesla.Env{} = env}
      assert env.method == :get
      assert Keyword.get(env.query, :limit) == 10
      assert Tesla.get_header(env, "x-custom") == "1"
      assert Tesla.get_header(env, "x-api-token") == "token"
    end

    test "POST/PUT/PATCH send body" do
      assert {:ok, _} = Raw.request(client(), :post, "deals", body: %{title: "A"})
      assert_received {:tesla_request, %Tesla.Env{method: :post, body: post_body}}
      assert Jason.decode!(post_body) == %{"title" => "A"}

      assert {:ok, _} =
               Raw.request(client(), :put, "deals/:id",
                 body: %{title: "B"},
                 opts: [path_params: [id: 3]]
               )

      assert_received {:tesla_request, %Tesla.Env{method: :put, url: put_url, body: put_body}}
      assert String.ends_with?(put_url, "/api/v2/deals/3")
      assert Jason.decode!(put_body) == %{"title" => "B"}

      assert {:ok, _} = Raw.request(client(), :patch, "/api/v2/deals/9", body: %{title: "C"})
      assert_received {:tesla_request, %Tesla.Env{method: :patch, body: patch_body}}
      assert Jason.decode!(patch_body) == %{"title" => "C"}
    end

    test "DELETE works without a body" do
      assert {:ok, _} = Raw.request(client(), :delete, "deals/:id", opts: [path_params: [id: 1]])
      assert_received {:tesla_request, %Tesla.Env{method: :delete, url: url}}
      assert String.ends_with?(url, "/api/v2/deals/1")
    end
  end

  describe "request/4 error normalization" do
    test "maps non-success HTTP status to ExPipedrive.Error" do
      c =
        client(%{
          status: 404,
          body: %{"success" => false, "error" => "Not Found"}
        })

      assert {:error, %Error{kind: :not_found, status: 404, message: "Not Found"}} =
               Raw.request(c, :get, "deals/missing")
    end

    test "maps transport failures to ExPipedrive.Error" do
      c = client({:error, :econnrefused})

      assert {:error, %Error{kind: :transport, reason: :econnrefused}} =
               Raw.request(c, :get, "deals")
    end

    test "treats success: false bodies as errors even on 200" do
      c = client(%{status: 200, body: %{"success" => false, "error" => "nope"}})

      assert {:error, %Error{message: "nope"}} = Raw.request(c, :get, "deals")
    end

    test "allows custom success_statuses" do
      c = client(%{status: 202, body: %{"accepted" => true}})

      assert {:error, %Error{status: 202}} = Raw.request(c, :post, "webhooks", body: %{})

      assert {:ok, %{"accepted" => true}} =
               Raw.request(c, :post, "webhooks", body: %{}, success_statuses: [202])
    end
  end

  describe "request/4 validation" do
    test "rejects unknown options" do
      assert_raise ArgumentError, ~r/unknown Raw.request options/, fn ->
        Raw.request(client(), :get, "deals", foo: 1)
      end
    end
  end
end
