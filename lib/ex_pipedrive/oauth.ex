defmodule ExPipedrive.Oauth do
  @moduledoc """
  Pipedrive OAuth helpers: authorize URL, code exchange, and token refresh.

  Token exchange and refresh return `ExPipedrive.Oauth.Token` bundles (access,
  refresh, expiry, scope, `api_domain`). Persist them via
  `ExPipedrive.Oauth.TokenStore` in host apps — core has no Ecto dependency.

  Legacy helpers `get_refresh_token/4` and `refresh_access_token/3` still return
  bare token strings for transitional callers.
  """

  use Tesla

  alias ExPipedrive.Error
  alias ExPipedrive.Oauth.Token

  @token_url "https://oauth.pipedrive.com/oauth/token"

  def authorization_url(client_id, redirect_url, state \\ "") do
    url =
      "https://oauth.pipedrive.com/oauth/authorize?client_id=#{client_id}&redirect_uri=#{redirect_url}"

    if state != "" do
      url <> "&state=" <> state
    else
      url
    end
  end

  @doc """
  Exchanges an authorization code for a full `Token` bundle.
  """
  @spec exchange_authorization_code(String.t(), String.t(), String.t(), String.t(), keyword()) ::
          {:ok, Token.t()} | {:error, Error.t()}
  def exchange_authorization_code(auth_code, client_id, client_secret, redirect_url, opts \\ []) do
    request_token(
      %{
        grant_type: "authorization_code",
        code: auth_code,
        redirect_uri: redirect_url
      },
      client_id,
      client_secret,
      opts
    )
  end

  @doc """
  Refreshes an access token, returning a full `Token` bundle.

  Pass `default_api_domain:` when the refresh response omits `api_domain` so
  the previous tenant domain is preserved.
  """
  @spec refresh(String.t(), String.t(), String.t(), keyword()) ::
          {:ok, Token.t()} | {:error, Error.t()}
  def refresh(refresh_token, client_id, client_secret, opts \\ [])
      when is_binary(refresh_token) and is_binary(client_id) and is_binary(client_secret) do
    request_token(
      %{grant_type: "refresh_token", refresh_token: refresh_token},
      client_id,
      client_secret,
      opts
    )
  end

  @doc """
  Returns a fresh token, refreshing when `Token.expired?/2` is true.

  Options: `:skew_seconds` (default 60), `:adapter`, `:token_url`,
  `:default_api_domain` (defaults to `token.api_domain` on refresh).
  """
  @spec ensure_fresh(Token.t(), String.t(), String.t(), keyword()) ::
          {:ok, Token.t()} | {:error, Error.t()}
  def ensure_fresh(%Token{} = token, client_id, client_secret, opts \\ []) do
    skew = Keyword.get(opts, :skew_seconds, 60)

    if Token.expired?(token, skew) do
      refresh_opts =
        opts
        |> Keyword.put_new(:default_api_domain, token.api_domain)

      refresh(token.refresh_token, client_id, client_secret, refresh_opts)
    else
      {:ok, token}
    end
  end

  @doc """
  Exchanges an auth code and returns only the refresh token string.

  Prefer `exchange_authorization_code/4` for new code.
  """
  def get_refresh_token(auth_code, client_id, client_secret, redirect_url) do
    case exchange_authorization_code(auth_code, client_id, client_secret, redirect_url) do
      {:ok, %Token{refresh_token: refresh_token}} -> {:ok, refresh_token}
      {:error, _} = error -> error
    end
  end

  @doc """
  Refreshes and returns only the access token string.

  Prefer `refresh/3` for new code.
  """
  def refresh_access_token(refresh_token, client_id, client_secret) do
    case refresh(refresh_token, client_id, client_secret) do
      {:ok, %Token{access_token: access_token}} -> {:ok, access_token}
      {:error, _} = error -> error
    end
  end

  defp request_token(body, client_id, client_secret, opts) do
    client = oauth_http_client(client_id, client_secret, opts)
    url = Keyword.get(opts, :token_url, @token_url)

    case post(client, url, body) do
      {:ok, %Tesla.Env{status: 401} = env} ->
        {:error, %{Error.from_env(decode_env(env)) | reason: :refresh_token_expired}}

      {:ok, %Tesla.Env{status: status} = env} when status in 200..299 ->
        env = decode_env(env)

        case env.body do
          %{"access_token" => _, "refresh_token" => _} = data ->
            token =
              Token.from_response(data,
                default_api_domain: Keyword.get(opts, :default_api_domain)
              )

            {:ok, token}

          _ ->
            {:error, Error.from_env(env)}
        end

      {:ok, %Tesla.Env{} = env} ->
        {:error, Error.from_env(decode_env(env))}

      {:error, %{status: 401} = reason} ->
        {:error,
         %Error{
           kind: :unauthorized,
           message: "refresh token expired",
           status: 401,
           reason: :refresh_token_expired,
           body: reason
         }}

      {:error, reason} ->
        {:error, Error.from_transport(reason)}
    end
  end

  defp oauth_http_client(client_id, client_secret, opts) do
    middleware = [
      {Tesla.Middleware.Headers, [{"authorization", auth_header(client_id, client_secret)}]},
      Tesla.Middleware.FormUrlencoded
    ]

    case Keyword.get(opts, :adapter) do
      nil -> Tesla.client(middleware)
      adapter -> Tesla.client(middleware, adapter)
    end
  end

  defp decode_env(%Tesla.Env{body: body} = env) when is_binary(body) do
    %{env | body: Jason.decode!(body)}
  end

  defp decode_env(%Tesla.Env{} = env), do: env

  defp auth_header(client_id, client_secret) do
    "Basic " <> Base.encode64(client_id <> ":" <> client_secret)
  end
end
