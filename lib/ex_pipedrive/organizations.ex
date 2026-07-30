defmodule ExPipedrive.Organizations do
  @moduledoc """
  This module encapsulates calls to the pipedrive organizations resource API
  """

  alias ExPipedrive.Organization
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias Tesla.Client

  def get_organization(%Client{} = client, org_id) do
    client
    |> Request.get("organizations/:id", api_version: :v1, opts: [path_params: [id: org_id]])
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"data" => org_data}}} ->
        {:ok, Organization.new(org_data)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def create_organization(%Client{} = client, %Organization{id: nil} = org) do
    client
    |> Request.post("organizations", org, api_version: :v1)
    |> case do
      {:ok, %Tesla.Env{status: 201, body: %{"data" => org_data}}} ->
        {:ok, Organization.new(org_data)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def list_organizations(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("organizations", api_version: :v1, query: [start: start, limit: limit])
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => nil} = body}} ->
        {:ok, PagedResult.new([], body)}

      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data} = body}} ->
        organizations =
          data
          |> Enum.map(fn organization -> Organization.new(organization) end)

        {:ok, PagedResult.new(organizations, body)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def search_organizations(%Client{} = client, term, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("organizations/search",
      api_version: :v1,
      query: [term: term, start: start, limit: limit]
    )
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data}}} ->
        organizations =
          data
          |> Map.get("items")
          |> Enum.map(fn item_container -> Organization.new(Map.get(item_container, "item")) end)

        {:ok, organizations}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def update_organization(%Client{} = client, org_id, body) do
    client
    |> Request.put("organizations/:id", body,
      api_version: :v1,
      opts: [path_params: [id: org_id]]
    )
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data}}} ->
        {:ok, Organization.new(data)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end
end
