defmodule ExPipedrive.Pipelines do
  @moduledoc """
  This module encapsulates calls to the pipedrive pipelines resource API
  """

  alias ExPipedrive.Deal
  alias ExPipedrive.Pipeline
  alias ExPipedrive.Request
  alias Tesla.Client

  def list_pipelines(%Client{} = client) do
    client
    |> Request.get("pipelines", api_version: :v1)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"data" => pipeline_data}}} ->
        pipelines =
          pipeline_data
          |> Enum.map(&Pipeline.new/1)

        {:ok, pipelines}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def list_pipeline_deals(%Client{} = client, pipeline_id) do
    client
    |> Request.get("pipelines/:id/deals",
      api_version: :v1,
      opts: [path_params: [id: pipeline_id]]
    )
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"data" => deal_data}}} ->
        deals =
          deal_data
          |> Enum.map(&Deal.new/1)

        {:ok, deals}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end
end
