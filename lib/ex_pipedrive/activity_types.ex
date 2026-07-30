defmodule ExPipedrive.ActivityTypes do
  @moduledoc """
  This module encapsulates calls to the pipedrive activity_types resource API
  """

  alias ExPipedrive.ActivityType
  alias ExPipedrive.Request
  alias Tesla.Client

  def list_activity_types(%Client{} = client) do
    client
    |> Request.get("activityTypes", api_version: :v1)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"data" => activity_type_data}}} ->
        activity_types =
          activity_type_data
          |> Enum.map(&ActivityType.new/1)

        {:ok, activity_types}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end
end
