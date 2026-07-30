defmodule ExPipedrive.ResourceTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Client
  alias ExPipedrive.Error
  alias ExPipedrive.Page
  alias ExPipedrive.Resource
  alias ExPipedrive.WriteAttrs

  defmodule LeadLabels do
    @behaviour ExPipedrive.Resource

    @impl true
    def path, do: "leadLabels"

    @impl true
    def decode(%{"id" => id} = data), do: %{id: id, name: data["name"], raw: data}

    @impl true
    def encode(attrs), do: WriteAttrs.take(attrs, ~w(name color))

    @impl true
    def list_query_keys, do: [:ids]
  end

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
          {:ok,
           %{
             env
             | status: 200,
               body: %{"success" => true, "data" => %{"id" => 1, "name" => "Hot"}}
           }}
      end
    end
  end

  defp client(response \\ nil) do
    Client.new("token", "http://example.test",
      adapter: {CaptureAdapter, [test_pid: self(), response: response]}
    )
  end

  describe "get/3" do
    test "GETs versioned collection path with path params and decodes" do
      assert {:ok, %{id: 1, name: "Hot"}} = Resource.get(LeadLabels, client(), 1)

      assert_received {:tesla_request, %Tesla.Env{method: :get, url: url}}
      assert String.ends_with?(url, "/api/v2/leadLabels/1")
    end
  end

  describe "create/3 and update/4" do
    test "POST encodes body and decodes data" do
      c =
        client(%{
          status: 201,
          body: %{"success" => true, "data" => %{"id" => 9, "name" => "Warm"}}
        })

      assert {:ok, %{id: 9, name: "Warm"}} =
               Resource.create(LeadLabels, c, %{name: "Warm", color: "yellow", ignored: true})

      assert_received {:tesla_request, %Tesla.Env{method: :post, body: body, url: url}}
      assert String.ends_with?(url, "/api/v2/leadLabels")
      assert Jason.decode!(body) == %{"name" => "Warm", "color" => "yellow"}
    end

    test "PATCH updates by id" do
      assert {:ok, %{id: 1}} = Resource.update(LeadLabels, client(), 1, %{name: "Updated"})

      assert_received {:tesla_request, %Tesla.Env{method: :patch, url: url, body: body}}
      assert String.ends_with?(url, "/api/v2/leadLabels/1")
      assert Jason.decode!(body) == %{"name" => "Updated"}
    end
  end

  describe "delete/3" do
    test "DELETE returns response body without decode" do
      c = client(%{status: 200, body: %{"success" => true}})

      assert {:ok, %{"success" => true}} = Resource.delete(LeadLabels, c, 1)
      assert_received {:tesla_request, %Tesla.Env{method: :delete, url: url}}
      assert String.ends_with?(url, "/api/v2/leadLabels/1")
    end
  end

  describe "list_page/3 and stream/3" do
    test "lists a cursor page with filter keys and limit" do
      c =
        client(%{
          status: 200,
          body: %{
            "success" => true,
            "data" => [%{"id" => 1, "name" => "A"}, %{"id" => 2, "name" => "B"}],
            "additional_data" => %{"next_cursor" => "abc"}
          }
        })

      assert {:ok, %Page{data: [a, b], next_cursor: "abc"}} =
               Resource.list_page(LeadLabels, c, ids: "1,2", limit: 50, noise: true)

      assert a.id == 1
      assert b.name == "B"

      assert_received {:tesla_request, %Tesla.Env{query: query}}
      assert Keyword.get(query, :limit) == 50
      assert Keyword.get(query, :ids) == "1,2"
      refute Keyword.has_key?(query, :noise)
    end

    test "streams across pages" do
      # First page has next_cursor; second does not. Use a stateful adapter via Agent.
      {:ok, agent} = Agent.start_link(fn -> 0 end)

      defmodule PageAdapter do
        @behaviour Tesla.Adapter

        @impl true
        def call(env, opts) do
          agent = Keyword.fetch!(opts, :agent)
          n = Agent.get_and_update(agent, fn i -> {i, i + 1} end)

          body =
            case n do
              0 ->
                %{
                  "success" => true,
                  "data" => [%{"id" => 1, "name" => "A"}],
                  "additional_data" => %{"next_cursor" => "next"}
                }

              _ ->
                %{
                  "success" => true,
                  "data" => [%{"id" => 2, "name" => "B"}],
                  "additional_data" => %{"next_cursor" => nil}
                }
            end

          {:ok, %{env | status: 200, body: body}}
        end
      end

      client =
        Client.new("token", "http://example.test", adapter: {PageAdapter, [agent: agent]})

      assert [%{id: 1}, %{id: 2}] =
               Resource.stream(LeadLabels, client, limit: 1) |> Enum.to_list()
    end
  end

  describe "errors" do
    test "normalizes HTTP failures" do
      c = client(%{status: 404, body: %{"success" => false, "error" => "missing"}})

      assert {:error, %Error{kind: :not_found}} = Resource.get(LeadLabels, c, 404)
    end
  end
end
