defmodule ExPipedrive.PersonFields do
  @moduledoc """
  This module encapsulates calls to the pipedrive person field resource API
  """

  alias ExPipedrive.Field
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias Tesla.Client

  def list_person_fields(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("personFields", api_version: :v1, query: [start: start, limit: limit])
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => nil} = body}} ->
        {:ok, PagedResult.new([], body)}

      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data} = body}} ->
        person_fields =
          data
          |> Enum.map(fn person_field -> Field.new(person_field) end)

        {:ok, PagedResult.new(person_fields, body)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end
end
