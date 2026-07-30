defmodule ExPipedrive.Activities do
  @moduledoc """
  This module encapsulates calls to the pipedrive activities resource API
  """

  alias ExPipedrive.Activity
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias Tesla.Client

  def add_activity(%Client{} = client, %Activity{id: nil} = activity) do
    client
    |> Request.post("activities", activity, api_version: :v1)
    |> case do
      {:ok, %Tesla.Env{status: 201, body: %{"data" => activity_data}}} ->
        {:ok, Activity.new(activity_data)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def list_activities(%Client{} = client, opts \\ []) do
    param_mappings = [
      {:limit, :limit, 100},
      {:cursor, :cursor, nil},
      {:since, :since, nil},
      {:until, :until, nil},
      {:user_id, :user_id, nil},
      {:done, :done, nil},
      {:type, :type, nil}
    ]

    params =
      Enum.reduce(param_mappings, [], fn {opt_key, param_key, default}, params ->
        case Keyword.get(opts, opt_key, default) do
          nil -> params
          value -> [{param_key, value} | params]
        end
      end)

    client
    |> Request.get("activities/collection", api_version: :v1, query: params)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true} = body}} ->
        {:ok,
         %PagedResult{
           success: true,
           data: Enum.map(body["data"], &Activity.new/1),
           additional_data: ExPipedrive.AdditionalData.new(body["additional_data"])
         }}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def list_own_activities(%Client{} = client, opts \\ []) do
    param_mappings = [
      {:limit, :limit, 100},
      {:start, :start, 0},
      {:done, :done, nil},
      {:type, :type, nil},
      {:start_date, :start_date, nil},
      {:end_date, :end_date, nil}
    ]

    params =
      Enum.reduce(param_mappings, [], fn {opt_key, param_key, default}, params ->
        case Keyword.get(opts, opt_key, default) do
          nil -> params
          value -> [{param_key, value} | params]
        end
      end)

    client
    |> Request.get("activities", api_version: :v1, query: params)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true} = body}} ->
        {:ok,
         %PagedResult{
           success: true,
           data: Enum.map(body["data"], &Activity.new/1),
           additional_data: ExPipedrive.AdditionalData.new(body["additional_data"])
         }}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end
end
