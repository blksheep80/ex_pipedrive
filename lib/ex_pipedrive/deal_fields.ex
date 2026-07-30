defmodule ExPipedrive.DealFields do
  @moduledoc """
  This module encapsulates calls to the pipedrive deal field resource API
  """

  alias ExPipedrive.Field
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias Tesla.Client

  def list_deal_fields(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("dealFields", api_version: :v1, query: [start: start, limit: limit])
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => nil} = body}} ->
        {:ok, PagedResult.new([], body)}

      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data} = body}} ->
        deal_fields =
          data
          |> Enum.map(fn deal_field -> Field.new(deal_field) end)

        {:ok, PagedResult.new(deal_fields, body)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end
end
