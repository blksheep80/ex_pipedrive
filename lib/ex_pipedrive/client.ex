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
  """

  alias ExPipedrive.Oauth

  @type auth_mode :: :header | :query

  @doc """
  Builds a Tesla client authenticated with a Pipedrive API token.

  ## Options

  - `:auth` — `:header` (default) sends `x-api-token`; `:query` is isolated
    legacy v1 query-param auth (`api_token`) for transitional use only.
  - `:adapter` — optional Tesla adapter (used in tests).
  """
  @spec new(String.t(), String.t(), keyword()) :: Tesla.Client.t()
  def new(api_token, api_domain, opts \\ [])
      when is_binary(api_token) and is_binary(api_domain) and is_list(opts) do
    auth = Keyword.get(opts, :auth, :header)
    adapter = Keyword.get(opts, :adapter)

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url(api_domain)},
      {Tesla.Middleware.JSON, engine: Jason},
      auth_middleware(api_token, auth),
      Tesla.Middleware.PathParams
    ]

    case adapter do
      nil -> Tesla.client(middleware)
      adapter -> Tesla.client(middleware, adapter)
    end
  end

  @doc """
  Builds a Tesla client by refreshing an OAuth access token once.

  Returns `{:ok, client}` or `{:error, reason}` from the token refresh.
  """
  @spec from_oauth(String.t(), String.t(), String.t(), String.t()) ::
          {:ok, Tesla.Client.t()} | {:error, term()}
  def from_oauth(refresh_token, client_id, client_secret, api_domain)
      when is_binary(refresh_token) and is_binary(client_id) and is_binary(client_secret) and
             is_binary(api_domain) do
    case Oauth.refresh_access_token(refresh_token, client_id, client_secret) do
      {:ok, access_token} ->
        middleware = [
          {Tesla.Middleware.BaseUrl, base_url(api_domain)},
          {Tesla.Middleware.BearerAuth, token: access_token},
          {Tesla.Middleware.JSON, engine: Jason},
          Tesla.Middleware.PathParams
        ]

        {:ok, Tesla.client(middleware)}

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
