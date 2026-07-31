defmodule ExPipedrive.Filters do
  @moduledoc """
  API v1 client for Pipedrive filters.

  Filters remain on `/api/v1/filters`; there is no `/api/v2` equivalent yet.
  All functions here explicitly route to `api_version: :v1`.

  ## Conditions

  `:conditions` is passed through as a plain map (not a typed struct) matching
  Pipedrive's nested AND/OR condition-group JSON shape. It requires a minimum
  structure of one first-level group glued with `"and"`, containing exactly
  two second-level groups — one glued `"and"`, the other `"or"`:

      %{
        "glue" => "and",
        "conditions" => [
          %{
            "glue" => "and",
            "conditions" => [
              %{
                "object" => "deal",
                "field_id" => 12_456,
                "operator" => ">",
                "value" => 1000,
                "extra_value" => nil
              }
            ]
          },
          %{"glue" => "or", "conditions" => []}
        ]
      }

  ## Example

      {:ok, filter} =
        ExPipedrive.Filters.create(client, %{
          name: "High value deals",
          type: "deals",
          conditions: conditions
        })

      {:ok, filters} = ExPipedrive.Filters.list(client, type: "deals")
      {:ok, filter} = ExPipedrive.Filters.get(client, filter.id)
      {:ok, filter} = ExPipedrive.Filters.update(client, filter.id, %{name: "Renamed"})
      {:ok, :ok} = ExPipedrive.Filters.delete(client, filter.id)
  """

  alias ExPipedrive.Filter
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(name conditions type)

  @doc """
  Lists filters via `GET /api/v1/filters`.

  Accepts an optional `:type` option (`"deals"`, `"leads"`, `"org"`,
  `"people"`, `"products"`, `"activity"`, `"projects"`) to scope results.

  Returns `{:ok, [%Filter{}]}`.
  """
  @spec list(Client.t(), keyword()) :: {:ok, [Filter.t()]} | {:error, ExPipedrive.Error.t()}
  def list(%Client{} = client, opts \\ []) do
    query = maybe_add_filter([], opts, :type)

    client
    |> Request.get("filters", api_version: :v1, query: query)
    |> Response.map([200], fn %{body: %{"data" => data}} ->
      Enum.map(data || [], &Filter.new/1)
    end)
  end

  @doc """
  Fetches a filter by id via `GET /api/v1/filters/:id`.

  Returns `{:ok, %Filter{}}`.
  """
  @spec get(Client.t(), pos_integer()) :: {:ok, Filter.t()} | {:error, ExPipedrive.Error.t()}
  def get(%Client{} = client, filter_id) do
    client
    |> Request.get("filters/:id", api_version: :v1, opts: [path_params: [id: filter_id]])
    |> Response.map([200], fn %{body: %{"data" => data}} ->
      Filter.new(data)
    end)
  end

  @doc """
  Creates a filter via `POST /api/v1/filters`.

  Accepts a map with `:name`, `:conditions`, and `:type` (required by
  Pipedrive). Returns `{:ok, %Filter{}}`.
  """
  @spec create(Client.t(), map()) :: {:ok, Filter.t()} | {:error, ExPipedrive.Error.t()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    client
    |> Request.post("filters", WriteAttrs.take(attrs, @write_fields), api_version: :v1)
    |> Response.map([200, 201], fn %{body: %{"data" => data}} ->
      Filter.new(data)
    end)
  end

  @doc """
  Updates a filter via `PUT /api/v1/filters/:id`.

  Accepts a map of `:name` and/or `:conditions`. Returns `{:ok, %Filter{}}`.
  """
  @spec update(Client.t(), pos_integer(), map()) ::
          {:ok, Filter.t()} | {:error, ExPipedrive.Error.t()}
  def update(%Client{} = client, filter_id, attrs) when is_map(attrs) do
    client
    |> Request.put(
      "filters/:id",
      WriteAttrs.take(attrs, @write_fields),
      api_version: :v1,
      opts: [path_params: [id: filter_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} ->
      Filter.new(data)
    end)
  end

  @doc """
  Deletes a filter via `DELETE /api/v1/filters/:id`.

  Returns `{:ok, :ok}`.
  """
  @spec delete(Client.t(), pos_integer()) :: {:ok, :ok} | {:error, ExPipedrive.Error.t()}
  def delete(%Client{} = client, filter_id) do
    client
    |> Request.delete("filters/:id", api_version: :v1, opts: [path_params: [id: filter_id]])
    |> Response.map([200], fn _env -> :ok end)
  end

  defp maybe_add_filter(query_params, opts, key) do
    case Keyword.get(opts, key) do
      nil -> query_params
      value -> Keyword.put(query_params, key, value)
    end
  end
end
