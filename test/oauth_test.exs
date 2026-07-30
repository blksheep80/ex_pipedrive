defmodule ExPipedrive.OauthTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Client
  alias ExPipedrive.Error
  alias ExPipedrive.Oauth
  alias ExPipedrive.Oauth.Token
  alias ExPipedrive.Oauth.TokenStore.Memory

  defmodule FakeOauthAdapter do
    @behaviour Tesla.Adapter

    @impl true
    def call(%Tesla.Env{method: :post, body: body} = env, opts) do
      responses = Keyword.fetch!(opts, :responses)
      params = decode_body(body)
      grant = params["grant_type"] || params[:grant_type]
      response = Map.fetch!(responses, grant)

      {:ok,
       %{
         env
         | status: response.status,
           body: Jason.encode!(response.body),
           headers: [{"content-type", "application/json"}]
       }}
    end

    defp decode_body(body) when is_binary(body), do: URI.decode_query(body)

    defp decode_body(body) when is_map(body) do
      Map.new(body, fn
        {k, v} when is_atom(k) -> {Atom.to_string(k), v}
        {k, v} -> {k, v}
      end)
    end
  end

  defp token_response(overrides \\ %{}) do
    Map.merge(
      %{
        "access_token" => "access-1",
        "token_type" => "Bearer",
        "refresh_token" => "refresh-1",
        "scope" => "base",
        "expires_in" => 3600,
        "api_domain" => "https://company.pipedrive.com"
      },
      overrides
    )
  end

  defp adapter(responses) do
    {FakeOauthAdapter, [responses: responses]}
  end

  describe "Token" do
    test "from_response computes expires_at from expires_in" do
      token = Token.from_response(token_response())

      assert token.access_token == "access-1"
      assert token.refresh_token == "refresh-1"
      assert token.api_domain == "https://company.pipedrive.com"
      assert token.expires_in == 3600
      assert %DateTime{} = token.expires_at
      refute Token.expired?(token, 0)
    end

    test "expired?/2 respects skew" do
      token = %Token{
        access_token: "a",
        refresh_token: "r",
        api_domain: "https://company.pipedrive.com",
        expires_at: DateTime.add(DateTime.utc_now(), 30, :second)
      }

      refute Token.expired?(token, 0)
      assert Token.expired?(token, 60)
    end

    test "preserves default_api_domain when response omits it" do
      token =
        Token.from_response(
          Map.delete(token_response(), "api_domain"),
          default_api_domain: "https://preserved.pipedrive.com"
        )

      assert token.api_domain == "https://preserved.pipedrive.com"
    end
  end

  describe "exchange_authorization_code/5" do
    test "returns a Token bundle" do
      assert {:ok, %Token{access_token: "access-1", refresh_token: "refresh-1"}} =
               Oauth.exchange_authorization_code(
                 "code",
                 "id",
                 "secret",
                 "https://app/callback",
                 adapter:
                   adapter(%{
                     "authorization_code" => %{status: 200, body: token_response()}
                   })
               )
    end
  end

  describe "refresh/4" do
    test "returns a Token and maps 401 to refresh_token_expired" do
      assert {:ok, %Token{access_token: "access-2", api_domain: "https://company.pipedrive.com"}} =
               Oauth.refresh("refresh-1", "id", "secret",
                 adapter:
                   adapter(%{
                     "refresh_token" => %{
                       status: 200,
                       body: token_response(%{"access_token" => "access-2"})
                     }
                   })
               )

      assert {:error, %Error{reason: :refresh_token_expired}} =
               Oauth.refresh("dead", "id", "secret",
                 adapter:
                   adapter(%{
                     "refresh_token" => %{status: 401, body: %{"success" => false}}
                   })
               )
    end
  end

  describe "ensure_fresh/4" do
    test "returns the same token when not expired" do
      token = Token.from_response(token_response(%{"expires_in" => 3600}))

      assert {:ok, ^token} = Oauth.ensure_fresh(token, "id", "secret", skew_seconds: 0)
    end

    test "refreshes when expired and preserves api_domain" do
      token = %Token{
        access_token: "old",
        refresh_token: "refresh-1",
        api_domain: "https://company.pipedrive.com",
        expires_at: DateTime.add(DateTime.utc_now(), -10, :second)
      }

      assert {:ok, %Token{access_token: "new", api_domain: "https://company.pipedrive.com"}} =
               Oauth.ensure_fresh(token, "id", "secret",
                 skew_seconds: 0,
                 adapter:
                   adapter(%{
                     "refresh_token" => %{
                       status: 200,
                       body: Map.delete(token_response(%{"access_token" => "new"}), "api_domain")
                     }
                   })
               )
    end
  end

  describe "TokenStore.Memory" do
    test "get/put round-trip" do
      Memory.start_link()
      id = "tenant-#{System.unique_integer([:positive])}"
      token = Token.from_response(token_response())

      assert {:error, :not_found} = Memory.get(id)
      assert :ok = Memory.put(id, token)
      assert {:ok, ^token} = Memory.get(id)
    end
  end

  describe "Client.from_token/2 and from_token_store/4" do
    test "from_token builds Bearer client from Token" do
      token = Token.from_response(token_response())
      client = Client.from_token(token)

      middleware_modules =
        Enum.map(client.pre, fn
          {module, _, _} -> module
          {module, _} -> module
          module when is_atom(module) -> module
        end)

      assert Tesla.Middleware.BearerAuth in middleware_modules
      assert Tesla.Middleware.BaseUrl in middleware_modules
    end

    test "from_token_store refreshes, persists, and returns client" do
      Memory.start_link()
      store_id = "tenant-#{System.unique_integer([:positive])}"

      token = %Token{
        access_token: "old",
        refresh_token: "refresh-1",
        api_domain: "https://company.pipedrive.com",
        expires_at: DateTime.add(DateTime.utc_now(), -5, :second)
      }

      assert {:ok, client, %Token{access_token: "fresh"}} =
               Client.from_token_store(token, "id", "secret",
                 store: Memory,
                 store_id: store_id,
                 skew_seconds: 0,
                 adapter:
                   adapter(%{
                     "refresh_token" => %{
                       status: 200,
                       body: token_response(%{"access_token" => "fresh"})
                     }
                   })
               )

      assert %Tesla.Client{} = client
      assert {:ok, %Token{access_token: "fresh"}} = Memory.get(store_id)
    end
  end
end
