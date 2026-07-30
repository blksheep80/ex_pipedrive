defmodule ExPipedrive.Oauth do
  @moduledoc """
  This module contains functions for authorizing with Pipedrive's OAuth server.
  """

  use Tesla

  alias ExPipedrive.Error

  def authorization_url(client_id, redirect_url, state \\ "") do
    url =
      "https://oauth.pipedrive.com/oauth/authorize?client_id=#{client_id}&redirect_uri=#{redirect_url}"

    if state != "" do
      url <> "&state=" <> state
    else
      url
    end
  end

  def get_refresh_token(auth_code, client_id, client_secret, redirect_url) do
    client =
      Tesla.client([
        {Tesla.Middleware.Headers, [{"authorization", auth_header(client_id, client_secret)}]},
        Tesla.Middleware.FormUrlencoded
      ])

    {:ok, resp} =
      post(client, "https://oauth.pipedrive.com/oauth/token", %{
        grant_type: "authorization_code",
        code: auth_code,
        redirect_uri: redirect_url
      })

    %{"refresh_token" => refresh_token} = Jason.decode!(resp.body)

    {:ok, refresh_token}
  end

  def refresh_access_token(refresh_token, client_id, client_secret) do
    client =
      Tesla.client([
        {Tesla.Middleware.Headers, [{"authorization", auth_header(client_id, client_secret)}]},
        Tesla.Middleware.FormUrlencoded
      ])

    case post(client, "https://oauth.pipedrive.com/oauth/token", %{
           grant_type: "refresh_token",
           refresh_token: refresh_token
         }) do
      {:ok, %Tesla.Env{status: 401} = env} ->
        {:error, %{Error.from_env(decode_env(env)) | reason: :refresh_token_expired}}

      {:ok, %Tesla.Env{} = env} ->
        env = decode_env(env)

        case env.body do
          %{"access_token" => token} ->
            {:ok, token}

          _ ->
            {:error, Error.from_env(env)}
        end

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

  defp decode_env(%Tesla.Env{body: body} = env) when is_binary(body) do
    %{env | body: Jason.decode!(body)}
  end

  defp decode_env(%Tesla.Env{} = env), do: env

  defp auth_header(client_id, client_secret) do
    "Basic " <> Base.encode64(client_id <> ":" <> client_secret)
  end
end
