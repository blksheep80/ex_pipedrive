defmodule ExPipedrive.Activities do
  @moduledoc """
  Pipedrive activities resource.

  v2-first helpers (`get/2`, `create/2`, `update/3`, `delete/2`, `list_page/2`,
  `stream/2`) talk to `/api/v2/activities` via `ExPipedrive.Resource`. Legacy
  `add_activity/2`, `list_activities/2`, and `list_own_activities/2` remain on
  API v1 for compatibility.
  """

  @behaviour ExPipedrive.Resource

  alias ExPipedrive.Activity
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Resource
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    subject type owner_id deal_id lead_id person_id org_id project_id
    due_date due_time duration busy done location participants attendees
    public_description priority note custom_fields
  )

  @impl true
  def path, do: "activities"

  @impl true
  def decode(data) when is_map(data), do: Activity.new(data)

  @impl true
  def encode(attrs), do: WriteAttrs.take(attrs, @write_fields)

  @impl true
  def list_query_keys do
    [:owner_id, :deal_id, :person_id, :org_id, :done, :lead_id]
  end

  # --- API v2 ---

  @doc """
  Fetches an activity by id via `GET /api/v2/activities/:id`.
  """
  def get(%Client{} = client, activity_id) do
    Resource.get(__MODULE__, client, activity_id)
  end

  @doc """
  Creates an activity via `POST /api/v2/activities`.

  Accepts a map (preferred) or `%Activity{}`. Returns `{:ok, %Activity{}}`.
  """
  def create(%Client{} = client, attrs) do
    Resource.create(__MODULE__, client, attrs)
  end

  @doc """
  Updates an activity via `PATCH /api/v2/activities/:id`.
  """
  def update(%Client{} = client, activity_id, attrs) do
    Resource.update(__MODULE__, client, activity_id, attrs)
  end

  @doc """
  Deletes an activity via `DELETE /api/v2/activities/:id`.
  """
  def delete(%Client{} = client, activity_id) do
    Resource.delete(__MODULE__, client, activity_id)
  end

  @doc """
  Lists one page of activities via API v2 cursor pagination.

  Options: `:cursor`, `:limit` (clamped to 500), `:owner_id`, `:deal_id`,
  `:person_id`, `:org_id`, `:done`, `:lead_id`.
  """
  def list_page(%Client{} = client, opts \\ []) do
    list_activities_page(client, opts)
  end

  @doc """
  Lazily streams activities across all v2 cursor pages until `next_cursor` is nil.
  """
  def stream(%Client{} = client, opts \\ []) do
    stream_activities(client, opts)
  end

  def list_activities_page(%Client{} = client, opts \\ []) do
    Resource.list_page(__MODULE__, client, opts)
  end

  def stream_activities(%Client{} = client, opts \\ []) do
    Resource.stream(__MODULE__, client, opts)
  end

  # --- API v1 (legacy) ---

  def add_activity(%Client{} = client, %Activity{id: nil} = activity) do
    client
    |> Request.post("activities", activity, api_version: :v1)
    |> Response.map([201], fn %{body: %{"data" => activity_data}} ->
      Activity.new(activity_data)
    end)
  end

  def list_activities(%Client{} = client, opts \\ []) do
    param_mappings = [
      {:limit, :limit, 100},
      {:cursor, :cursor, nil},
      {:since, :since, nil},
      {:until, :until, nil},
      {:user_id, :user_id, nil},
      {:done, :done, nil},
      {:type, :type, nil}
    ]

    params =
      Enum.reduce(param_mappings, [], fn {opt_key, param_key, default}, params ->
        case Keyword.get(opts, opt_key, default) do
          nil -> params
          value -> [{param_key, value} | params]
        end
      end)

    client
    |> Request.get("activities/collection", api_version: :v1, query: params)
    |> Response.map([200], fn %{body: %{"success" => true} = body} ->
      %PagedResult{
        success: true,
        data: Enum.map(body["data"], &Activity.new/1),
        additional_data: ExPipedrive.AdditionalData.new(body["additional_data"])
      }
    end)
  end

  def list_own_activities(%Client{} = client, opts \\ []) do
    param_mappings = [
      {:limit, :limit, 100},
      {:start, :start, 0},
      {:done, :done, nil},
      {:type, :type, nil},
      {:start_date, :start_date, nil},
      {:end_date, :end_date, nil}
    ]

    params =
      Enum.reduce(param_mappings, [], fn {opt_key, param_key, default}, params ->
        case Keyword.get(opts, opt_key, default) do
          nil -> params
          value -> [{param_key, value} | params]
        end
      end)

    client
    |> Request.get("activities", api_version: :v1, query: params)
    |> Response.map([200], fn %{body: %{"success" => true} = body} ->
      %PagedResult{
        success: true,
        data: Enum.map(body["data"], &Activity.new/1),
        additional_data: ExPipedrive.AdditionalData.new(body["additional_data"])
      }
    end)
  end
end
