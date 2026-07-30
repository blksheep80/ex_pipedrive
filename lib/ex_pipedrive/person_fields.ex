defmodule LineDrive.PersonFields do
  @moduledoc """
  This module encapsulates calls to the pipedrive person field resource API
  """

  use Tesla

  alias LineDrive.Field
  alias LineDrive.PagedResult
  alias Tesla.Client

  @callback list_person_fields(Client.t(), [any()]) :: {:ok, PagedResult.t()}

  def list_person_fields(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> get("/api/v1/personFields", query: [start: start, limit: limit])
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
