defmodule ExPipedrive.Persons do
  @moduledoc """
  This module encapsulates calls to the pipedrive person resource API
  """

  alias ExPipedrive.PagedResult
  alias ExPipedrive.Person
  alias ExPipedrive.Request
  alias Tesla.Client

  def get_person(%Client{} = client, id) do
    client
    |> Request.get("persons/:id", api_version: :v1, opts: [path_params: [id: id]])
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data}}} ->
        {:ok, Person.new(data)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def create_person(%Client{} = client, %Person{id: nil} = person) do
    client
    |> Request.post("persons", person, api_version: :v1)
    |> case do
      {:ok, %Tesla.Env{status: 201, body: %{"data" => person_data}}} ->
        {:ok, Person.new(person_data)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def list_persons(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("persons", api_version: :v1, query: [start: start, limit: limit])
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => nil} = body}} ->
        {:ok, PagedResult.new([], body)}

      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data} = body}} ->
        persons =
          data
          |> Enum.map(fn person -> Person.new(person) end)

        {:ok, PagedResult.new(persons, body)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def search_persons(%Client{} = client, term, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("persons/search",
      api_version: :v1,
      query: [term: term, start: start, limit: limit]
    )
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data}}} ->
        persons =
          data
          |> Map.get("items")
          |> Enum.map(fn item_container ->
            Person.new_from_search(Map.get(item_container, "item"))
          end)

        {:ok, persons}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end
end
