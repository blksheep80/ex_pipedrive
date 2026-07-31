defmodule ExPipedrive.LeadSources do
  @moduledoc """
  API v1 client for Pipedrive lead sources.

  Lead sources are a fixed list maintained by Pipedrive (not user-editable).
  All leads created through the API are assigned the `"API"` source.
  """

  alias ExPipedrive.LeadSource
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  @doc """
  Lists all lead sources via `GET /api/v1/leadSources`.

  This endpoint does not support pagination.
  """
  @spec list(Client.t()) :: {:ok, [LeadSource.t()]} | {:error, ExPipedrive.Error.t()}
  def list(%Client{} = client) do
    client
    |> Request.get("leadSources", api_version: :v1)
    |> Response.map([200], fn %{body: %{"data" => data}} ->
      data |> List.wrap() |> Enum.map(&LeadSource.new/1)
    end)
  end
end
