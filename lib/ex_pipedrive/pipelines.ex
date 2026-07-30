defmodule LineDrive.Pipelines do
  @moduledoc """
  This module encapsulates calls to the pipedrive pipelines resource API
  """
  use Tesla

  alias LineDrive.Deal
  alias LineDrive.Pipeline
  alias Tesla.Client

  @callback list_pipelines(Client.t()) :: {:ok, Pipeline.t()}

  def list_pipelines(%Client{} = client) do
    client
    |> get("/api/v1/pipelines")
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
    |> get("/api/v1/pipelines/#{pipeline_id}/deals")
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
