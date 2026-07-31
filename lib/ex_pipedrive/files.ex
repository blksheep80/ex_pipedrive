defmodule ExPipedrive.Files do
  @moduledoc """
  API v1 client for Pipedrive files (attachments).

  Files remain on `/api/v1/files` (multipart upload). There is no `/api/v2`
  equivalent yet — every function here uses `api_version: :v1`.

  ## Uploads

  Uploads use `multipart/form-data` via `Tesla.Multipart`. Associate a file with
  a deal, person, organization, activity, product, lead, or project by passing
  the corresponding id option to `upload/4` / `create/4`.

  Pipedrive enforces per-company file size limits (commonly up to ~50 MB per
  file — confirm in company settings). Request volume is subject to the usual
  API rate limits; clients already retry 429 via `ExPipedrive.Middleware.Retry`.

  ## Downloads

  `download/2` calls `GET /api/v1/files/:id/download` and returns the raw body
  bytes. Metadata still includes a `url` that can be fetched with a plain HTTP
  GET when preferred.

  ## Remote files (Google Drive)

  `create_remote/2` and `remote_link/2` cover Pipedrive's Google Drive helpers
  (`POST /files/remote` and `/files/remoteLink`).

  ## Example

      {:ok, file} =
        ExPipedrive.Files.upload(client, "hello", "note.txt", deal_id: 1)

      {:ok, files} = ExPipedrive.Files.list(client, deal_id: 1)
      {:ok, file} = ExPipedrive.Files.get(client, file.id)
      {:ok, binary} = ExPipedrive.Files.download(client, file.id)
      {:ok, :ok} = ExPipedrive.Files.delete(client, file.id)
  """

  alias ExPipedrive.File
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client
  alias Tesla.Multipart

  @link_fields [
    {:deal_id, "deal_id"},
    {:person_id, "person_id"},
    {:org_id, "org_id"},
    {:product_id, "product_id"},
    {:activity_id, "activity_id"},
    {:lead_id, "lead_id"},
    {:project_id, "project_id"}
  ]
  @update_fields ~w(name description)
  @remote_create_fields ~w(file_type title item_type item_id remote_location)
  @remote_link_fields ~w(item_type item_id remote_id remote_location)

  @doc """
  Lists files via `GET /api/v1/files`.

  Options: `:start`, `:limit` (max 100), `:sort` (`id`, `update_time`), and
  association filters when supported by your Pipedrive plan (`:deal_id`,
  `:person_id`, `:org_id`, `:product_id`, `:activity_id`, `:lead_id`,
  `:project_id`).

  Returns `{:ok, %PagedResult{}}`.
  """
  @spec list(Client.t(), keyword()) ::
          {:ok, PagedResult.t()} | {:error, ExPipedrive.Error.t()}
  def list(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = opts |> Keyword.get(:limit, 100) |> min(100)

    query =
      [start: start, limit: limit]
      |> maybe_put(opts, :sort)
      |> maybe_put_all(opts, [
        :deal_id,
        :person_id,
        :org_id,
        :product_id,
        :activity_id,
        :lead_id,
        :project_id
      ])

    client
    |> Request.get("files", api_version: :v1, query: query)
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} ->
        PagedResult.new(Enum.map(data, &File.new/1), body)
    end)
  end

  @doc """
  Fetches file metadata via `GET /api/v1/files/:id`.
  """
  @spec get(Client.t(), pos_integer()) :: {:ok, File.t()} | {:error, ExPipedrive.Error.t()}
  def get(%Client{} = client, file_id) do
    client
    |> Request.get("files/:id", api_version: :v1, opts: [path_params: [id: file_id]])
    |> Response.map([200], fn %{body: %{"data" => data}} -> File.new(data) end)
  end

  @doc """
  Downloads file bytes via `GET /api/v1/files/:id/download`.

  Returns `{:ok, binary}` on success.
  """
  @spec download(Client.t(), pos_integer()) :: {:ok, binary()} | {:error, ExPipedrive.Error.t()}
  def download(%Client{} = client, file_id) do
    client
    |> Request.get("files/:id/download", api_version: :v1, opts: [path_params: [id: file_id]])
    |> Response.map([200], fn %{body: body} -> body end)
  end

  @doc """
  Uploads a file via `POST /api/v1/files` (`multipart/form-data`).

  Same as `upload/4`.
  """
  @spec create(Client.t(), iodata(), String.t(), keyword()) ::
          {:ok, File.t()} | {:error, ExPipedrive.Error.t()}
  def create(%Client{} = client, content, filename, opts \\ [])
      when (is_binary(content) or is_list(content)) and is_binary(filename) do
    upload(client, content, filename, opts)
  end

  @doc """
  Uploads a file via `POST /api/v1/files` (`multipart/form-data`).

  `content` is the file body; `filename` is the original name sent as the
  multipart filename. Link options: `:deal_id`, `:person_id`, `:org_id`,
  `:product_id`, `:activity_id`, `:lead_id`, `:project_id`.
  """
  @spec upload(Client.t(), iodata(), String.t(), keyword()) ::
          {:ok, File.t()} | {:error, ExPipedrive.Error.t()}
  def upload(%Client{} = client, content, filename, opts \\ [])
      when (is_binary(content) or is_list(content)) and is_binary(filename) and is_list(opts) do
    binary = IO.iodata_to_binary(content)

    multipart =
      Multipart.new()
      |> Multipart.add_file_content(binary, filename, name: "file")
      |> add_link_fields(opts)

    client
    |> Request.post("files", multipart, api_version: :v1)
    |> Response.map([200, 201], fn %{body: %{"data" => data}} -> File.new(data) end)
  end

  @doc """
  Updates file details via `PUT /api/v1/files/:id`.

  Accepts `:name` and/or `:description`.
  """
  @spec update(Client.t(), pos_integer(), map()) ::
          {:ok, File.t()} | {:error, ExPipedrive.Error.t()}
  def update(%Client{} = client, file_id, attrs) when is_map(attrs) do
    client
    |> Request.put(
      "files/:id",
      WriteAttrs.take(attrs, @update_fields),
      api_version: :v1,
      opts: [path_params: [id: file_id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} -> File.new(data) end)
  end

  @doc """
  Deletes a file via `DELETE /api/v1/files/:id`.

  Returns `{:ok, :ok}`.
  """
  @spec delete(Client.t(), pos_integer()) :: {:ok, :ok} | {:error, ExPipedrive.Error.t()}
  def delete(%Client{} = client, file_id) do
    client
    |> Request.delete("files/:id", api_version: :v1, opts: [path_params: [id: file_id]])
    |> Response.map([200], fn _env -> :ok end)
  end

  @doc """
  Creates an empty Google Drive file and links it via `POST /api/v1/files/remote`.

  Required map keys (string or atom): `file_type`, `title`, `item_type`,
  `item_id`, `remote_location` (typically `"googledrive"`).
  """
  @spec create_remote(Client.t(), map()) :: {:ok, File.t()} | {:error, ExPipedrive.Error.t()}
  def create_remote(%Client{} = client, attrs) when is_map(attrs) do
    client
    |> Request.post(
      "files/remote",
      form_body(WriteAttrs.take(attrs, @remote_create_fields)),
      api_version: :v1,
      headers: [{"content-type", "application/x-www-form-urlencoded"}]
    )
    |> Response.map([200, 201], fn %{body: %{"data" => data}} -> File.new(data) end)
  end

  @doc """
  Links an existing remote (Google Drive) file via `POST /api/v1/files/remoteLink`.

  Required map keys: `item_type`, `item_id`, `remote_id`, `remote_location`.
  """
  @spec remote_link(Client.t(), map()) :: {:ok, File.t()} | {:error, ExPipedrive.Error.t()}
  def remote_link(%Client{} = client, attrs) when is_map(attrs) do
    client
    |> Request.post(
      "files/remoteLink",
      form_body(WriteAttrs.take(attrs, @remote_link_fields)),
      api_version: :v1,
      headers: [{"content-type", "application/x-www-form-urlencoded"}]
    )
    |> Response.map([200, 201], fn %{body: %{"data" => data}} -> File.new(data) end)
  end

  defp add_link_fields(%Multipart{} = multipart, opts) do
    Enum.reduce(@link_fields, multipart, fn {opt_key, field_name}, acc ->
      case Keyword.get(opts, opt_key) do
        nil -> acc
        value -> Multipart.add_field(acc, field_name, to_string(value))
      end
    end)
  end

  defp form_body(attrs) when is_map(attrs) do
    attrs
    |> Enum.map(fn {k, v} -> {to_string(k), to_string(v)} end)
    |> URI.encode_query()
  end

  defp maybe_put(query, opts, key) do
    case Keyword.get(opts, key) do
      nil -> query
      value -> Keyword.put(query, key, value)
    end
  end

  defp maybe_put_all(query, opts, keys) do
    Enum.reduce(keys, query, fn key, acc -> maybe_put(acc, opts, key) end)
  end
end
