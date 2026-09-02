defmodule ExPipedrivePhoenix.Install do
  @moduledoc """
  Authorize-redirect and callback helpers for Pipedrive marketplace OAuth.

  `use ExPipedrivePhoenix.Install, opts` defines `authorize/2` and `callback/2`
  on a Phoenix controller. See the package README for a router example.

  Independent of Überauth — uses `ExPipedrive.Oauth` and `TokenStore` from core.
  """

  import Phoenix.Controller
  import Plug.Conn

  alias ExPipedrive.Oauth
  alias ExPipedrive.Oauth.Token

  @session_state :ex_pipedrive_oauth_state

  defmacro __using__(opts) do
    quote do
      def authorize(conn, _params) do
        ExPipedrivePhoenix.Install.authorize(conn, unquote(opts))
      end

      def callback(conn, params) do
        ExPipedrivePhoenix.Install.callback(conn, params, unquote(opts))
      end

      defoverridable authorize: 2, callback: 2
    end
  end

  @doc """
  Puts a CSRF state in the session and redirects to Pipedrive authorize.
  """
  @spec authorize(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def authorize(conn, opts) do
    opts = config(opts)
    state = Base.url_encode64(:crypto.strong_rand_bytes(16), padding: false)

    conn
    |> put_session(@session_state, state)
    |> redirect(external: Oauth.authorization_url(opts[:client_id], opts[:redirect_uri], state))
  end

  @doc """
  Exchanges `code`, persists the token, and redirects to `:success_to`.
  """
  @spec callback(Plug.Conn.t(), map(), keyword()) :: Plug.Conn.t()
  def callback(conn, params, opts) do
    opts = config(opts)

    with {:ok, _state} <- check_state(conn, params),
         {:ok, code} <- fetch_code(params),
         {:ok, %Token{} = token} <- exchange(code, opts),
         :ok <- persist(token, conn, opts) do
      conn
      |> delete_session(@session_state)
      |> redirect(to: Keyword.get(opts, :success_to, "/"))
    else
      {:error, _reason} ->
        conn
        |> delete_session(@session_state)
        |> redirect(to: Keyword.get(opts, :error_to, "/"))
    end
  end

  defp config(opts) do
    otp_app = Keyword.get(opts, :otp_app, :ex_pipedrive_phoenix)
    Keyword.merge(Application.get_env(otp_app, ExPipedrivePhoenix, []), opts)
  end

  defp check_state(conn, params) do
    expected = get_session(conn, @session_state)
    given = params["state"] || params[:state]

    if is_binary(expected) and expected != "" and
         Plug.Crypto.secure_compare(expected, to_string(given || "")) do
      {:ok, expected}
    else
      {:error, :invalid_state}
    end
  end

  defp fetch_code(params) do
    case params["code"] || params[:code] do
      code when is_binary(code) and code != "" -> {:ok, code}
      _ -> {:error, :missing_code}
    end
  end

  defp exchange(code, opts) do
    Oauth.exchange_authorization_code(
      code,
      Keyword.fetch!(opts, :client_id),
      Keyword.fetch!(opts, :client_secret),
      Keyword.fetch!(opts, :redirect_uri),
      Keyword.take(opts, [:adapter, :token_url])
    )
  end

  defp persist(token, conn, opts) do
    store = Keyword.fetch!(opts, :token_store)
    store.put(tenant_from_conn(conn, opts), token)
  end

  defp tenant_from_conn(conn, opts) do
    cond do
      Keyword.has_key?(opts, :tenant_id) ->
        Keyword.fetch!(opts, :tenant_id)

      assign = Keyword.get(opts, :tenant_assign) ->
        Map.get(conn.assigns, assign) ||
          raise ArgumentError, "conn.assigns[#{inspect(assign)}] is missing"

      true ->
        raise ArgumentError, "set :tenant_id or :tenant_assign on ExPipedrivePhoenix.Install"
    end
  end
end
