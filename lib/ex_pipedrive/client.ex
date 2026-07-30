defmodule ExPipedrive.Client do
  @moduledoc """
  Builds authenticated Tesla clients for the Pipedrive API.

  Centralizes base URL / `api_domain` handling. Pass either a full URL
  (`https://company.pipedrive.com`) or a host (`company.pipedrive.com`);
  versioned paths (`/api/v2`, `/api/v1`) are owned by `ExPipedrive.Request`.
  """

  alias ExPipedrive.Oauth

  @doc """
  Builds a Tesla client authenticated with a Pipedrive API token.

  Auth is currently sent as the `api_token` query parameter (v1-compatible).
  Header-based `x-api-token` auth lands in a follow-up.
  """
  @spec new(String.t(), String.t()) :: Tesla.Client.t()
  def new(api_token, api_domain) when is_binary(api_token) and is_binary(api_domain) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url(api_domain)},
      {Tesla.Middleware.JSON, engine: Jason},
      {Tesla.Middleware.Query, api_token: api_token},
      Tesla.Middleware.PathParams
    ]

    Tesla.client(middleware)
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

  defp ensure_scheme(url) do
    if Regex.match?(~r/^https?:\/\//i, url) do
      url
    else
      "https://" <> url
    end
  end
end
