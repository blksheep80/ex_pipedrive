defmodule ExPipedrive.OrganizationFields do
  @moduledoc """
  This module encapsulates calls to the pipedrive organization fields resource API
  """

  alias ExPipedrive.Field
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias Tesla.Client

  def list_organization_fields(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("organizationFields",
      api_version: :v1,
      query: [start: start, limit: limit]
    )
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => nil} = body}} ->
        {:ok, PagedResult.new([], body)}

      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data} = body}} ->
        organization_fields =
          data
          |> Enum.map(fn organization_field -> Field.new(organization_field) end)

        {:ok, PagedResult.new(organization_fields, body)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end
end
