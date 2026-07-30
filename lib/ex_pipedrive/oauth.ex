defmodule LineDrive.Oauth do
  @moduledoc """
  This module contains functions for authorizing with Pipedrive's OAuth server.
  """

  use Tesla

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

    with {:ok, resp} <-
           post(client, "https://oauth.pipedrive.com/oauth/token", %{
             grant_type: "refresh_token",
             refresh_token: refresh_token
           }),
         %{"access_token" => token} <- Jason.decode!(resp.body) do
      {:ok, token}
    else
      {:error, %{status: 401}} ->
        {:error, :refresh_token_expired}

      %{"success" => false, "message" => message} ->
        {:error, message}

      error ->
        error
    end
  end

  defp auth_header(client_id, client_secret) do
    "Basic " <> Base.encode64(client_id <> ":" <> client_secret)
  end
end
