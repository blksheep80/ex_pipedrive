defmodule ExPipedrive.ActivityTypes do
  @moduledoc """
  This module encapsulates calls to the pipedrive activity_types resource API
  """

  alias ExPipedrive.ActivityType
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  def list_activity_types(%Client{} = client) do
    client
    |> Request.get("activityTypes", api_version: :v1)
    |> Response.map([200], fn %{body: %{"data" => activity_type_data}} ->
      Enum.map(activity_type_data, &ActivityType.new/1)
    end)
  end
end
