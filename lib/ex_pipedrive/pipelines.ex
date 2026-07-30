defmodule ExPipedrive.Pipelines do
  @moduledoc """
  This module encapsulates calls to the pipedrive pipelines resource API
  """

  alias ExPipedrive.Deal
  alias ExPipedrive.Pipeline
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  def list_pipelines(%Client{} = client) do
    client
    |> Request.get("pipelines", api_version: :v1)
    |> Response.map([200], fn %{body: %{"data" => pipeline_data}} ->
      Enum.map(pipeline_data, &Pipeline.new/1)
    end)
  end

  def list_pipeline_deals(%Client{} = client, pipeline_id) do
    client
    |> Request.get("pipelines/:id/deals",
      api_version: :v1,
      opts: [path_params: [id: pipeline_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => deal_data}} ->
      Enum.map(deal_data, &Deal.new/1)
    end)
  end
end
