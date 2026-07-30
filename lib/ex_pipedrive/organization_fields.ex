defmodule ExPipedrive.OrganizationFields do
  @moduledoc """
  This module encapsulates calls to the pipedrive organization fields resource API
  """

  alias ExPipedrive.Field
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  def list_organization_fields(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("organizationFields",
      api_version: :v1,
      query: [start: start, limit: limit]
    )
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} ->
        PagedResult.new(Enum.map(data, &Field.new/1), body)
    end)
  end
end
