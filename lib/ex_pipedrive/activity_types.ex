defmodule LineDrive.ActivityTypes do
  @moduledoc """
  This module encapsulates calls to the pipedrive activity_types resource API
  """
  use Tesla

  alias LineDrive.ActivityType

  alias Tesla.Client

  @callback list_activity_types(Client.t()) :: {:ok, ActivityType.t()}

  def list_activity_types(%Client{} = client) do
    client
    |> get("/api/v1/activityTypes")
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
