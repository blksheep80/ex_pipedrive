defmodule ExPipedrive.Notes do
  @moduledoc """
  This module encapsulates calls to the pipedrive notes resource API
  """

  alias ExPipedrive.Note
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias Tesla.Client

  def add_note(%Client{} = client, %Note{id: nil} = note) do
    client
    |> Request.post("notes", note, api_version: :v1)
    |> case do
      {:ok, %Tesla.Env{status: 201, body: %{"data" => note_data}}} ->
        {:ok, Note.new(note_data)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def get_all_org_notes(%Client{} = client, org_id, opts \\ []) do
    sort = Keyword.get(opts, :sort, "add_time DESC")
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 20)

    client
    |> Request.get("notes",
      api_version: :v1,
      query: [org_id: org_id, start: start, limit: limit, sort: sort]
    )
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data}}} ->
        notes =
          data
          |> Enum.map(fn note_container ->
            Note.new(note_container)
          end)

        {:ok, notes}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  def list_notes(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)
    sort = Keyword.get(opts, :sort, "add_time DESC")

    query_params =
      [start: start, limit: limit, sort: sort]
      |> maybe_add_filter(opts, :user_id)
      |> maybe_add_filter(opts, :lead_id)
      |> maybe_add_filter(opts, :deal_id)
      |> maybe_add_filter(opts, :person_id)
      |> maybe_add_filter(opts, :org_id)
      |> maybe_add_filter(opts, :project_id)
      |> maybe_add_filter(opts, :start_date)
      |> maybe_add_filter(opts, :end_date)
      |> maybe_add_filter(opts, :pinned_to_lead_flag)
      |> maybe_add_filter(opts, :pinned_to_deal_flag)
      |> maybe_add_filter(opts, :pinned_to_organization_flag)
      |> maybe_add_filter(opts, :pinned_to_person_flag)

    client
    |> Request.get("notes", api_version: :v1, query: query_params)
    |> case do
      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => nil} = body}} ->
        {:ok, PagedResult.new([], body)}

      {:ok, %Tesla.Env{status: 200, body: %{"success" => true, "data" => data} = body}} ->
        {:ok, PagedResult.new(Enum.map(data, &Note.new/1), body)}

      {:ok, %Tesla.Env{body: %{"success" => false, "error" => message}}} ->
        {:error, message}

      {:error, env} ->
        {:error, env}
    end
  end

  defp maybe_add_filter(query_params, opts, key) do
    case Keyword.get(opts, key) do
      nil -> query_params
      value -> Keyword.put(query_params, key, value)
    end
  end
end
