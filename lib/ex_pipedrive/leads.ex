defmodule ExPipedrive.Leads do
  @moduledoc """
  This module encapsulates calls to the pipedrive leads resource API
  """

  alias ExPipedrive.Lead
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias Tesla.Client

  def create_lead(%Client{} = client, %Lead{id: nil} = lead) do
    client
    |> Request.post("leads", lead, api_version: :v1)
    |> case do
      {:ok, %Tesla.Env{status: 201, body: %{"data" => lead_data}}} ->
        {:ok, Lead.new(lead_data)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def get_lead(%Client{} = client, lead_id) do
    client
    |> Request.get("leads/:id", api_version: :v1, opts: [path_params: [id: lead_id]])
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"data" => lead_data}}} ->
        {:ok, Lead.new(lead_data)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def list_leads(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    query_params =
      [start: start, limit: limit]
      |> maybe_add_filter(opts, :owner_id)
      |> maybe_add_filter(opts, :person_id)
      |> maybe_add_filter(opts, :organization_id)
      |> maybe_add_filter(opts, :filter_id)
      |> maybe_add_filter(opts, :sort)

    client
    |> Request.get("leads", api_version: :v1, query: query_params)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => nil} = body}} ->
        {:ok, PagedResult.new([], body)}

      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data} = body}} ->
        {:ok, PagedResult.new(Enum.map(data, &Lead.new/1), body)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  defp maybe_add_filter(query_params, opts, key) do
    case Keyword.get(opts, key) do
      nil -> query_params
      value -> Keyword.put(query_params, key, value)
    end
  end

  def search_leads(%Client{} = client, term, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("leads/search",
      api_version: :v1,
      query: [term: term, start: start, limit: limit]
    )
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data}}} ->
        leads =
          data
          |> Map.get("items")
          |> Enum.map(fn item_container -> Lead.new(Map.get(item_container, "item")) end)

        {:ok, leads}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end
end
