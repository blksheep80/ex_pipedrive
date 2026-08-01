defmodule ExPipedrive.Notes do
  @moduledoc """
  API v1 shim for Pipedrive notes.

  All functions in this module explicitly route to `/api/v1/notes`. Prefer the
  `get/2`, `create/2`, and `list/2` aliases for new code; `add_note/2` and
  `list_notes/2` remain supported for compatibility. A v2 Notes resource can
  replace this shim without changing callers that use those aliases.

  ## List return shapes

  Paginated note lists return `{:ok, %ExPipedrive.PagedResult{}}` (v1 offset
  pagination). Prefer `list/2` with filters such as `:org_id` over
  `get_all_org_notes/2` (kept as a thin wrapper that returns the same
  `PagedResult` shape).
  """

  alias ExPipedrive.Note
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    content user_id org_id person_id deal_id lead_id project_id
    pinned_to_organization_flag pinned_to_person_flag pinned_to_deal_flag
    pinned_to_lead_flag pinned_to_project_flag
  )

  @doc """
  Creates a note through `POST /api/v1/notes`.

  Accepts a map (preferred) or `%Note{}` and returns `{:ok, %Note{}}`.
  """
  def create(%Client{} = client, attrs), do: add_note(client, attrs)

  @doc """
  Soft-deprecated: prefer `create/2`.

  Creates a note through `POST /api/v1/notes`.
  """
  def add_note(%Client{} = client, attrs) when is_map(attrs) do
    client
    |> Request.post("notes", WriteAttrs.take(attrs, @write_fields), api_version: :v1)
    |> Response.map([201], fn %{body: %{"data" => note_data}} ->
      Note.new(note_data)
    end)
  end

  @doc """
  Fetches a note by id through `GET /api/v1/notes/:id`.
  """
  def get(%Client{} = client, note_id), do: get_note(client, note_id)

  @doc """
  Soft-deprecated: prefer `get/2`.

  Fetches a note by id through `GET /api/v1/notes/:id`.
  """
  def get_note(%Client{} = client, note_id) do
    client
    |> Request.get("notes/:id", api_version: :v1, opts: [path_params: [id: note_id]])
    |> Response.map([200], fn %{body: %{"data" => note_data}} ->
      Note.new(note_data)
    end)
  end

  @doc """
  Soft-deprecated: prefer `list/2` with `org_id:`.

  Lists notes for an organization via `GET /api/v1/notes?org_id=…`.

  Prefer `list/2` with `:org_id` for new code. Returns
  `{:ok, %PagedResult{}}` (same as `list/2`).

  Accepts either `get_all_org_notes(client, org_id, opts)` or
  `get_all_org_notes(client, org_id: id, …)` for historical call sites.
  """
  def get_all_org_notes(%Client{} = client, opts) when is_list(opts) do
    opts = Keyword.put_new(opts, :limit, 20)
    list(client, opts)
  end

  @doc """
  Soft-deprecated: prefer `list/2` with `org_id:`.
  """
  def get_all_org_notes(%Client{} = client, org_id, opts \\ []) do
    get_all_org_notes(client, Keyword.put(opts, :org_id, org_id))
  end

  @doc """
  Lists notes through `GET /api/v1/notes`.

  Supports the legacy v1 pagination and filtering options accepted by
  `list_notes/2`. Returns `{:ok, %PagedResult{}}`.
  """
  def list(%Client{} = client, opts \\ []), do: list_notes(client, opts)

  @doc """
  Soft-deprecated: prefer `list/2`.

  Lists notes through `GET /api/v1/notes`.
  """
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
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} ->
        PagedResult.new(Enum.map(data, &Note.new/1), body)
    end)
  end

  defp maybe_add_filter(query_params, opts, key) do
    case Keyword.get(opts, key) do
      nil -> query_params
      value -> Keyword.put(query_params, key, value)
    end
  end
end
