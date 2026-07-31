defmodule ExPipedrive.LeadLabels do
  @moduledoc """
  API v1 shim for Pipedrive lead labels.

  Unlike Deal/Person/Organization labels (option values on a `label_ids`
  field), Leads have a dedicated `/api/v1/leadLabels` endpoint with full
  CRUD except a single-item `get` — `GET /leadLabels` always returns every
  label (no pagination, no filtering).

  Assigning or clearing labels on a lead is done through
  `ExPipedrive.Leads.update/3` with a `label_ids` attribute (a list of label
  ids) — there is no separate assign/clear endpoint.
  """

  alias ExPipedrive.Error
  alias ExPipedrive.Label
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(name color)

  @doc """
  Lists all lead labels via `GET /api/v1/leadLabels`.

  This endpoint does not support pagination — all labels are always
  returned.
  """
  @spec list(Client.t()) :: {:ok, [Label.t()]} | {:error, Error.t()}
  def list(%Client{} = client) do
    client
    |> Request.get("leadLabels", api_version: :v1)
    |> Response.map([200], fn %{body: %{"data" => data}} ->
      data |> List.wrap() |> Enum.map(&Label.new/1)
    end)
  end

  @doc """
  Creates a lead label via `POST /api/v1/leadLabels`.

  Accepts a map (preferred) or `%Label{}` with `:name` and `:color`. `color`
  must be one of `green`, `blue`, `red`, `yellow`, `purple`, or `gray`.
  """
  @spec create(Client.t(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def create(%Client{} = client, attrs) do
    client
    |> Request.post("leadLabels", WriteAttrs.take(attrs, @write_fields), api_version: :v1)
    |> Response.map([200, 201], fn %{body: %{"data" => label_data}} -> Label.new(label_data) end)
  end

  @doc """
  Updates a lead label via `PATCH /api/v1/leadLabels/:id`.

  Only properties included in `attrs` are updated.
  """
  @spec update(Client.t(), term(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def update(%Client{} = client, id, attrs) do
    client
    |> Request.patch("leadLabels/:id", WriteAttrs.take(attrs, @write_fields),
      api_version: :v1,
      opts: [path_params: [id: id]]
    )
    |> Response.map([200], fn %{body: %{"data" => label_data}} -> Label.new(label_data) end)
  end

  @doc """
  Deletes a lead label via `DELETE /api/v1/leadLabels/:id`.
  """
  @spec delete(Client.t(), term()) :: {:ok, term()} | {:error, Error.t()}
  def delete(%Client{} = client, id) do
    client
    |> Request.delete("leadLabels/:id", api_version: :v1, opts: [path_params: [id: id]])
    |> Response.map([200], fn %{body: body} -> body end)
  end
end
