defmodule ExPipedrive.Organizations do
  @moduledoc """
  This module encapsulates calls to the pipedrive organizations resource API
  """

  alias ExPipedrive.Organization
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  def get_organization(%Client{} = client, org_id) do
    client
    |> Request.get("organizations/:id", api_version: :v1, opts: [path_params: [id: org_id]])
    |> Response.map([200], fn %{body: %{"data" => org_data}} ->
      Organization.new(org_data)
    end)
  end

  def create_organization(%Client{} = client, %Organization{id: nil} = org) do
    client
    |> Request.post("organizations", org, api_version: :v1)
    |> Response.map([201], fn %{body: %{"data" => org_data}} ->
      Organization.new(org_data)
    end)
  end

  def list_organizations(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("organizations", api_version: :v1, query: [start: start, limit: limit])
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} ->
        PagedResult.new(Enum.map(data, &Organization.new/1), body)
    end)
  end

  def search_organizations(%Client{} = client, term, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("organizations/search",
      api_version: :v1,
      query: [term: term, start: start, limit: limit]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      data
      |> Map.get("items")
      |> Enum.map(fn item_container -> Organization.new(Map.get(item_container, "item")) end)
    end)
  end

  def update_organization(%Client{} = client, org_id, body) do
    client
    |> Request.put("organizations/:id", body,
      api_version: :v1,
      opts: [path_params: [id: org_id]]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      Organization.new(data)
    end)
  end
end
