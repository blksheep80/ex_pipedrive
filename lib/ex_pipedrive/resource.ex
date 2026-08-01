defmodule ExPipedrive.Resource do
  @moduledoc """
  Behaviour and HTTP helpers for Pipedrive resource modules.

  Core v2 modules implement this behaviour and delegate CRUD / list / stream to
  the helpers below: `Products`, `Stages`, `Deals`, `Persons`, `Organizations`,
  `Activities`, and `Pipelines`. Host apps can do the same for endpoints
  without a first-class module. Prefer `ExPipedrive.Raw` for one-off untyped
  calls. Nested or v1-only modules may intentionally skip this behaviour.

  ## Callbacks

  - `path/0` — collection segment (e.g. `"products"`); versioned via `Request`
  - `decode/1` — map API `data` item into a struct or map
  - `encode/1` — map/struct write attrs into a JSON body (usually `WriteAttrs.take/2`)
  - `list_query_keys/0` — optional filter keys for `list_page/3` / `stream/3`

  ## Custom resource example

      defmodule MyApp.Pipedrive.LeadLabels do
        @behaviour ExPipedrive.Resource

        alias ExPipedrive.Resource
        alias ExPipedrive.WriteAttrs

        @impl true
        def path, do: "leadLabels"

        @impl true
        def decode(data) when is_map(data), do: data

        @impl true
        def encode(attrs), do: WriteAttrs.take(attrs, ~w(name color))

        @impl true
        def list_query_keys, do: [:ids]

        def get(client, id), do: Resource.get(__MODULE__, client, id)
        def create(client, attrs), do: Resource.create(__MODULE__, client, attrs)
        def update(client, id, attrs), do: Resource.update(__MODULE__, client, id, attrs)
        def delete(client, id), do: Resource.delete(__MODULE__, client, id)
        def list_page(client, opts \\ []), do: Resource.list_page(__MODULE__, client, opts)
        def stream(client, opts \\ []), do: Resource.stream(__MODULE__, client, opts)
      end
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.Error
  alias ExPipedrive.Page
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  @type t :: module()

  @callback path() :: String.t()
  @callback decode(map()) :: term()
  @callback encode(term()) :: map()
  @callback list_query_keys() :: [atom()]

  @optional_callbacks list_query_keys: 0

  @doc """
  `GET /api/v2/{path}/:id` → `decode/1` on `data`.
  """
  @spec get(t(), Client.t(), term(), keyword()) :: {:ok, term()} | {:error, Error.t()}
  def get(resource, %Client{} = client, id, opts \\ []) when is_atom(resource) do
    {version_opts, _} = Keyword.split(opts, [:api_version])

    client
    |> Request.get("#{resource.path()}/:id", [
      {:opts, [path_params: [id: id]]} | version_opts
    ])
    |> Response.map([200], fn %{body: %{"data" => data}} ->
      resource.decode(data)
    end)
  end

  @doc """
  `POST /api/v2/{path}` with `encode/1` body → `decode/1` on `data`.

  Success statuses default to `[200, 201]` (Pipedrive varies by resource).
  Override with `:success_statuses`.
  """
  @spec create(t(), Client.t(), term(), keyword()) :: {:ok, term()} | {:error, Error.t()}
  def create(resource, %Client{} = client, attrs, opts \\ []) when is_atom(resource) do
    {version_opts, opts} = Keyword.split(opts, [:api_version])
    statuses = Keyword.get(opts, :success_statuses, [200, 201])
    body = resource.encode(attrs)

    client
    |> Request.post(resource.path(), body, version_opts)
    |> Response.map(statuses, fn %{body: %{"data" => data}} ->
      resource.decode(data)
    end)
  end

  @doc """
  `PATCH /api/v2/{path}/:id` with `encode/1` body → `decode/1` on `data`.
  """
  @spec update(t(), Client.t(), term(), term(), keyword()) ::
          {:ok, term()} | {:error, Error.t()}
  def update(resource, %Client{} = client, id, attrs, opts \\ []) when is_atom(resource) do
    {version_opts, _} = Keyword.split(opts, [:api_version])
    body = resource.encode(attrs)

    client
    |> Request.patch("#{resource.path()}/:id", body, [
      {:opts, [path_params: [id: id]]} | version_opts
    ])
    |> Response.map([200], fn %{body: %{"data" => data}} ->
      resource.decode(data)
    end)
  end

  @doc """
  `DELETE /api/v2/{path}/:id`. Returns the decoded response body (not `decode/1`).
  """
  @spec delete(t(), Client.t(), term(), keyword()) :: {:ok, term()} | {:error, Error.t()}
  def delete(resource, %Client{} = client, id, opts \\ []) when is_atom(resource) do
    {version_opts, _} = Keyword.split(opts, [:api_version])

    client
    |> Request.delete("#{resource.path()}/:id", [
      {:opts, [path_params: [id: id]]} | version_opts
    ])
    |> Response.map([200], fn %{body: body} -> body end)
  end

  @doc """
  Lists one cursor page via `GET /api/v2/{path}`.

  Builds the query from `:cursor`, `:limit` (clamped), and keys from
  `list_query_keys/0` when implemented. Returns `{:ok, %ExPipedrive.Page{}}`.
  """
  @spec list_page(t(), Client.t(), keyword()) :: {:ok, Page.t()} | {:error, Error.t()}
  def list_page(resource, %Client{} = client, opts \\ []) when is_atom(resource) do
    {version_opts, opts} = Keyword.split(opts, [:api_version])
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))

    query =
      opts
      |> Keyword.take([:cursor | list_query_keys(resource)])
      |> Keyword.put(:limit, limit)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.uniq_by(fn {k, _} -> k end)

    client
    |> Request.get(resource.path(), [{:query, query} | version_opts])
    |> Response.map([200], fn %{body: body} ->
      items =
        body
        |> Map.get("data")
        |> List.wrap()
        |> Enum.map(&resource.decode/1)

      Page.from_items(items, body)
    end)
  end

  @doc """
  Lazily streams decoded items across all v2 cursor pages.
  """
  @spec stream(t(), Client.t(), keyword()) :: Enumerable.t()
  def stream(resource, %Client{} = client, opts \\ []) when is_atom(resource) do
    Cursor.stream(
      fn page_opts ->
        list_page(resource, client, Keyword.merge(opts, page_opts))
      end,
      opts
    )
  end

  defp list_query_keys(resource) do
    if function_exported?(resource, :list_query_keys, 0) do
      resource.list_query_keys()
    else
      []
    end
  end
end
