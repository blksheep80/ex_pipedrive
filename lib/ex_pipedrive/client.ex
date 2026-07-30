defmodule ExPipedrive.Client do
  @moduledoc """
  Builds authenticated Tesla clients for the Pipedrive API.

  Centralizes base URL / `api_domain` handling. Pass either a full URL
  (`https://company.pipedrive.com`) or a host (`company.pipedrive.com`);
  versioned paths (`/api/v2`, `/api/v1`) are owned by `ExPipedrive.Request`.

  ## API token auth

  By default, API tokens are sent via the `x-api-token` header (compatible with
  Pipedrive API v1 and v2). Legacy query-param auth (`?api_token=...`) is
  available only via `auth: :query` for transitional v1 callers and should not
  be used for new code.

  ## OAuth

  Prefer `from_token/2` with an `ExPipedrive.Oauth.Token` bundle. Use
  `ExPipedrive.Oauth.ensure_fresh/4` (and a `TokenStore`) before building a
  client when tokens may be near expiry. `from_oauth/4` remains a one-shot
  refresh helper for scripts.

  ## Retries, telemetry, and middleware

  By default clients include:

  - `ExPipedrive.Middleware.Telemetry` — `[:ex_pipedrive, :request, …]` events
    (no logging; attach your own handlers)
  - `ExPipedrive.Middleware.Retry` — 429 / 502–504 / transport retries with
    `Retry-After` awareness

  Options on `new/3` and `from_token/2`:

  - `:retry` — `true` (default), `false`, or keyword opts for the retry middleware
  - `:telemetry` — `true` (default), `false`, or keyword opts (`:metadata`, …)
  - `:middleware` — extra Tesla middleware list (innermost, closest to adapter)
  - `:adapter` — optional Tesla adapter (tests)
  """

  alias ExPipedrive.Middleware
  alias ExPipedrive.Oauth
  alias ExPipedrive.Oauth.Token

  @type auth_mode :: :header | :query

  @doc """
  Builds a Tesla client authenticated with a Pipedrive API token.

  ## Options

  - `:auth` — `:header` (default) sends `x-api-token`; `:query` is isolated
    legacy v1 query-param auth (`api_token`) for transitional use only.
  - `:retry` — `true` (default), `false`, or keyword options for
    `ExPipedrive.Middleware.Retry`
  - `:telemetry` — `true` (default), `false`, or keyword options for
    `ExPipedrive.Middleware.Telemetry`
  - `:middleware` — additional Tesla middleware (after core stack)
  - `:adapter` — optional Tesla adapter (used in tests).
  """
  @spec new(String.t(), String.t(), keyword()) :: Tesla.Client.t()
  def new(api_token, api_domain, opts \\ [])
      when is_binary(api_token) and is_binary(api_domain) and is_list(opts) do
    auth = Keyword.get(opts, :auth, :header)
    adapter = Keyword.get(opts, :adapter)

    core = [
      {Tesla.Middleware.BaseUrl, base_url(api_domain)},
      {Tesla.Middleware.JSON, engine: Jason},
      auth_middleware(api_token, auth),
      Tesla.Middleware.PathParams
    ]

    build_client(stack(core, opts), adapter)
  end

  @doc """
  Builds a Tesla client from an OAuth `Token` (Bearer + `api_domain`).

  Does not refresh. Call `Oauth.ensure_fresh/4` first when needed.

  Accepts the same `:retry`, `:telemetry`, `:middleware`, and `:adapter`
  options as `new/3`.
  """
  @spec from_token(Token.t(), keyword()) :: Tesla.Client.t()
  def from_token(%Token{access_token: access_token, api_domain: api_domain}, opts \\ [])
      when is_binary(access_token) and is_binary(api_domain) do
    adapter = Keyword.get(opts, :adapter)

    core = [
      {Tesla.Middleware.BaseUrl, base_url(api_domain)},
      {Tesla.Middleware.BearerAuth, token: access_token},
      {Tesla.Middleware.JSON, engine: Jason},
      Tesla.Middleware.PathParams
    ]

    build_client(stack(core, opts), adapter)
  end

  @doc """
  Ensures the token is fresh (refreshing if needed), optionally persists it,
  and builds a Tesla client.

  Options:
  - `:store` / `:store_id` — when both set, saves the (possibly refreshed) token
  - `:skew_seconds`, `:adapter`, and other `Oauth.ensure_fresh/4` options
  - plus `from_token/2` middleware options (`:retry`, `:telemetry`, `:middleware`)
  """
  @spec from_token_store(Token.t(), String.t(), String.t(), keyword()) ::
          {:ok, Tesla.Client.t(), Token.t()} | {:error, term()}
  def from_token_store(%Token{} = token, client_id, client_secret, opts \\ []) do
    with {:ok, fresh} <- Oauth.ensure_fresh(token, client_id, client_secret, opts),
         :ok <- maybe_persist(fresh, opts) do
      {:ok, from_token(fresh, opts), fresh}
    end
  end

  @doc """
  Builds a Tesla client by refreshing an OAuth access token once.

  Returns `{:ok, client}` or `{:error, reason}` from the token refresh.
  Prefer `from_token/2` / `from_token_store/4` when you already hold a `Token`.
  """
  @spec from_oauth(String.t(), String.t(), String.t(), String.t(), keyword()) ::
          {:ok, Tesla.Client.t()} | {:error, term()}
  def from_oauth(refresh_token, client_id, client_secret, api_domain, opts \\ [])
      when is_binary(refresh_token) and is_binary(client_id) and is_binary(client_secret) and
             is_binary(api_domain) do
    refresh_opts = Keyword.put_new(opts, :default_api_domain, api_domain)

    case Oauth.refresh(refresh_token, client_id, client_secret, refresh_opts) do
      {:ok, %Token{} = token} ->
        {:ok, from_token(token, opts)}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Normalizes an `api_domain` or base URL to an absolute URL without a trailing slash.
  """
  @spec base_url(String.t()) :: String.t()
  def base_url(api_domain) when is_binary(api_domain) do
    api_domain
    |> String.trim()
    |> String.trim_trailing("/")
    |> ensure_scheme()
  end

  defp stack(core, opts) do
    extra = List.wrap(Keyword.get(opts, :middleware, []))

    []
    |> maybe_prepend_telemetry(opts)
    |> maybe_prepend_retry(opts)
    |> Kernel.++(core)
    |> Kernel.++(extra)
  end

  defp maybe_prepend_telemetry(stack, opts) do
    case Keyword.get(opts, :telemetry, true) do
      false ->
        stack

      true ->
        [{Middleware.Telemetry, []} | stack]

      telemetry_opts when is_list(telemetry_opts) ->
        [{Middleware.Telemetry, telemetry_opts} | stack]
    end
  end

  defp maybe_prepend_retry(stack, opts) do
    case Keyword.get(opts, :retry, true) do
      false -> stack
      true -> [{Middleware.Retry, []} | stack]
      retry_opts when is_list(retry_opts) -> [{Middleware.Retry, retry_opts} | stack]
    end
  end

  defp maybe_persist(token, opts) do
    store = Keyword.get(opts, :store)
    store_id = Keyword.get(opts, :store_id)

    if store && store_id do
      store.put(store_id, token)
    else
      :ok
    end
  end

  defp build_client(middleware, nil), do: Tesla.client(middleware)
  defp build_client(middleware, adapter), do: Tesla.client(middleware, adapter)

  defp auth_middleware(api_token, :header) do
    {Tesla.Middleware.Headers, [{"x-api-token", api_token}]}
  end

  defp auth_middleware(api_token, :query) do
    # Isolated legacy v1 auth — prefer `:header` (default).
    {Tesla.Middleware.Query, api_token: api_token}
  end

  defp auth_middleware(_api_token, other) do
    raise ArgumentError,
          "unsupported auth #{inspect(other)}; expected :header or :query"
  end

  defp ensure_scheme(url) do
    if Regex.match?(~r/^https?:\/\//i, url) do
      url
    else
      "https://" <> url
    end
  end
end
