defmodule ExPipedrivePhoenix.InstallTest do
  use ExUnit.Case, async: true

  import Phoenix.ConnTest
  import Plug.Conn

  alias ExPipedrive.Oauth.Token
  alias ExPipedrive.Oauth.TokenStore.Memory
  alias ExPipedrivePhoenix.Install

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

  setup do
    Memory.start_link()
    Memory.clear()
    :ok
  end

  defp token_response do
    %{
      "access_token" => "access-1",
      "token_type" => "Bearer",
      "refresh_token" => "refresh-1",
      "scope" => "base",
      "expires_in" => 3600,
      "api_domain" => "https://company.pipedrive.com"
    }
  end

  defp opts(extra \\ []) do
    Keyword.merge(
      [
        client_id: "id",
        client_secret: "secret",
        redirect_uri: "https://app.test/pipedrive/callback",
        token_store: Memory,
        tenant_id: "acme",
        success_to: "/ok",
        error_to: "/fail",
        adapter:
          {FakeOauthAdapter,
           [responses: %{"authorization_code" => %{status: 200, body: token_response()}}]}
      ],
      extra
    )
  end

  defp session_conn(path \\ "/pipedrive/install") do
    :get
    |> Phoenix.ConnTest.build_conn(path)
    |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
    |> Plug.Test.init_test_session(%{})
  end

  test "authorize/2 redirects to Pipedrive with state" do
    conn = Install.authorize(session_conn(), opts())

    location = redirected_to(conn, 302)
    assert location =~ "https://oauth.pipedrive.com/oauth/authorize"
    assert location =~ "client_id=id"
    state = get_session(conn, :ex_pipedrive_oauth_state)
    assert is_binary(state)
    assert location =~ "state=#{state}"
  end

  test "callback/2 persists a token on valid state" do
    conn = Install.authorize(session_conn(), opts())
    state = get_session(conn, :ex_pipedrive_oauth_state)

    conn =
      "/pipedrive/callback"
      |> session_conn()
      |> Plug.Test.init_test_session(%{ex_pipedrive_oauth_state: state})
      |> Install.callback(%{"code" => "code-1", "state" => state}, opts())

    assert redirected_to(conn, 302) == "/ok"
    assert {:ok, %Token{access_token: "access-1"}} = Memory.get("acme")
  end

  test "callback/2 rejects invalid state" do
    conn = Install.authorize(session_conn(), opts())
    state = get_session(conn, :ex_pipedrive_oauth_state)

    conn =
      "/pipedrive/callback"
      |> session_conn()
      |> Plug.Test.init_test_session(%{ex_pipedrive_oauth_state: state})
      |> Install.callback(%{"code" => "code-1", "state" => "nope"}, opts())

    assert redirected_to(conn, 302) == "/fail"
    assert {:error, :not_found} = Memory.get("acme")
  end
end
