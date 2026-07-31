defmodule ExPipedrive.NoteFields do
  @moduledoc """
  API v1 client for Pipedrive note field definitions.

  Note fields remain on `/api/v1/noteFields`; there is no `/api/v2`
  equivalent and no single-field get endpoint. Use `list/1` for reads.
  """

  alias ExPipedrive.Error
  alias ExPipedrive.Field
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  @doc """
  Lists note field definitions via `GET /api/v1/noteFields`.

  Returns `{:ok, [%Field{}]}`.
  """
  @spec list(Client.t()) :: {:ok, [Field.t()]} | {:error, Error.t()}
  def list(%Client{} = client) do
    client
    |> Request.get("noteFields", api_version: :v1)
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil}} ->
        []

      %{body: %{"success" => true, "data" => data}} when is_list(data) ->
        Enum.map(data, &Field.new/1)
    end)
  end

  @doc """
  Alias for `list/1`.
  """
  @spec list_note_fields(Client.t()) :: {:ok, [Field.t()]} | {:error, Error.t()}
  defdelegate list_note_fields(client), to: __MODULE__, as: :list
end
