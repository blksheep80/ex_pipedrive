defmodule ExPipedrive.OrganizationLabels do
  @moduledoc """
  Organization label definitions via the system `label_ids` field.

  Pipedrive does not expose a dedicated `organizationLabels` endpoint —
  organization labels are option values on the `label_ids` field returned by
  `GET /api/v2/organizationFields`. This module wraps the API v2 bulk
  field-options endpoints (`POST` / `PATCH` / `DELETE
  /api/v2/organizationFields/label_ids/options`) so label definitions can be
  listed and managed without hand-rolling `ExPipedrive.Raw` calls.

  Assigning or clearing labels on an organization is done through
  `ExPipedrive.Organizations.update/3` with a `label_ids` attribute (a list
  of label ids) — there is no separate assign/clear endpoint.
  """

  alias ExPipedrive.Error
  alias ExPipedrive.Label
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @field_code "label_ids"
  @field_path "organizationFields/:field_code"
  @options_path "organizationFields/:field_code/options"
  @write_fields ~w(label color)

  @doc """
  Lists organization label definitions via
  `GET /api/v2/organizationFields/label_ids`.
  """
  @spec list(Client.t()) :: {:ok, [Label.t()]} | {:error, Error.t()}
  def list(%Client{} = client) do
    client
    |> Request.get(@field_path, opts: [path_params: [field_code: @field_code]])
    |> Response.map([200], fn %{body: %{"data" => data}} ->
      data
      |> Map.get("options")
      |> List.wrap()
      |> Enum.map(&Label.new/1)
    end)
  end

  @doc """
  Adds an organization label via
  `POST /api/v2/organizationFields/label_ids/options`.

  Accepts a map (preferred) or `%Label{}` with `:label` and optional
  `:color`. Returns the created `%Label{}`.
  """
  @spec create(Client.t(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def create(%Client{} = client, attrs) do
    client
    |> Request.post(@options_path, [WriteAttrs.take(attrs, @write_fields)],
      opts: [path_params: [field_code: @field_code]]
    )
    |> Response.map([200], fn %{body: %{"data" => [option | _]}} -> Label.new(option) end)
  end

  @doc """
  Updates an organization label via
  `PATCH /api/v2/organizationFields/label_ids/options`.
  """
  @spec update(Client.t(), term(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def update(%Client{} = client, id, attrs) do
    body = [Map.put(WriteAttrs.take(attrs, @write_fields), "id", id)]

    client
    |> Request.patch(@options_path, body, opts: [path_params: [field_code: @field_code]])
    |> Response.map([200], fn %{body: %{"data" => [option | _]}} -> Label.new(option) end)
  end

  @doc """
  Deletes an organization label via
  `DELETE /api/v2/organizationFields/label_ids/options`.

  Returns the deleted `%Label{}`.
  """
  @spec delete(Client.t(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def delete(%Client{} = client, id) do
    client
    |> Request.delete(@options_path,
      body: [%{"id" => id}],
      opts: [path_params: [field_code: @field_code]]
    )
    |> Response.map([200], fn %{body: %{"data" => [option | _]}} -> Label.new(option) end)
  end
end
