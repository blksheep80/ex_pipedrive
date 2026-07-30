defmodule ExPipedrive.PersonFields do
  @moduledoc """
  API v2 person field definitions.

  `field_code` is the hash used as a key in `%ExPipedrive.Person{}.custom_fields`;
  `field_name` is its human-readable label. Use `ExPipedrive.Fields` to resolve
  between them.
  """

  alias ExPipedrive.Cursor
  alias ExPipedrive.Field
  alias ExPipedrive.Page
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  @doc """
  Lists one cursor page of person field definitions via `GET /api/v2/personFields`.

  Options: `:cursor`, `:limit` (clamped to 500), and `:include_fields`.
  """
  @spec list_page(Client.t(), keyword()) :: {:ok, Page.t()} | {:error, ExPipedrive.Error.t()}
  def list_page(%Client{} = client, opts \\ []) do
    limit = Cursor.clamp_limit(Keyword.get(opts, :limit))

    query =
      opts
      |> Keyword.take([:cursor, :include_fields])
      |> Keyword.put(:limit, limit)
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)

    client
    |> Request.get("personFields", query: query)
    |> Response.map([200], fn %{body: body} ->
      fields =
        body
        |> Map.get("data")
        |> List.wrap()
        |> Enum.map(&Field.new/1)

      Page.from_items(fields, body)
    end)
  end

  @doc """
  Lazily streams person field definitions across API v2 cursor pages.
  """
  @spec stream(Client.t(), keyword()) :: Enumerable.t()
  def stream(%Client{} = client, opts \\ []) do
    Cursor.stream(fn page_opts -> list_page(client, Keyword.merge(opts, page_opts)) end, opts)
  end

  @doc """
  Alias for `list_page/2`.
  """
  @spec list_person_fields(Client.t(), keyword()) ::
          {:ok, Page.t()} | {:error, ExPipedrive.Error.t()}
  def list_person_fields(%Client{} = client, opts \\ []), do: list_page(client, opts)
end
