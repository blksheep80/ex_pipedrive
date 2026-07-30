defmodule ExPipedrive.Persons do
  @moduledoc """
  This module encapsulates calls to the pipedrive person resource API
  """

  alias ExPipedrive.PagedResult
  alias ExPipedrive.Person
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  def get_person(%Client{} = client, id) do
    client
    |> Request.get("persons/:id", api_version: :v1, opts: [path_params: [id: id]])
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      Person.new(data)
    end)
  end

  def create_person(%Client{} = client, %Person{id: nil} = person) do
    client
    |> Request.post("persons", person, api_version: :v1)
    |> Response.map([201], fn %{body: %{"data" => person_data}} ->
      Person.new(person_data)
    end)
  end

  def list_persons(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("persons", api_version: :v1, query: [start: start, limit: limit])
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} ->
        PagedResult.new(Enum.map(data, &Person.new/1), body)
    end)
  end

  def search_persons(%Client{} = client, term, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("persons/search",
      api_version: :v1,
      query: [term: term, start: start, limit: limit]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      data
      |> Map.get("items")
      |> Enum.map(fn item_container ->
        Person.new_from_search(Map.get(item_container, "item"))
      end)
    end)
  end
end
