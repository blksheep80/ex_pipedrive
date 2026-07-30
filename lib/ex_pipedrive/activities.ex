defmodule LineDrive.Activities do
  @moduledoc """
  This module encapsulates calls to the pipedrive activities resource API
  """
  use Tesla

  alias LineDrive.Activity
  alias LineDrive.PagedResult

  alias Tesla.Client

  @callback add_activity(Client.t(), Activity.t()) :: {:ok, Activity.t()}
  @callback list_activities(Client.t(), keyword()) :: {:ok, PagedResult.t()}
  @callback list_own_activities(Client.t(), keyword()) :: {:ok, PagedResult.t()}

  def add_activity(%Client{} = client, %Activity{id: nil} = activity) do
    client
    |> post("/api/v1/activities", activity)
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
    |> get("/api/v1/activities/collection", query: params)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true} = body}} ->
        {:ok,
         %PagedResult{
           success: true,
           data: Enum.map(body["data"], &Activity.new/1),
           additional_data: LineDrive.AdditionalData.new(body["additional_data"])
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
    |> get("/api/v1/activities", query: params)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true} = body}} ->
        {:ok,
         %PagedResult{
           success: true,
           data: Enum.map(body["data"], &Activity.new/1),
           additional_data: LineDrive.AdditionalData.new(body["additional_data"])
         }}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end
end
