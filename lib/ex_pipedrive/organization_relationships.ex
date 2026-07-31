defmodule ExPipedrive.OrganizationRelationships do
  @moduledoc """
  API v1 client for Pipedrive organization relationships.

  Organization relationships remain on `/api/v1/organizationRelationships`;
  there is no `/api/v2` equivalent. All functions here explicitly route to
  `api_version: :v1`.

  ## Example

      {:ok, relationship} =
        ExPipedrive.OrganizationRelationships.create(client, %{
          type: "parent",
          rel_owner_org_id: 1,
          rel_linked_org_id: 2
        })

      {:ok, relationships} = ExPipedrive.OrganizationRelationships.list(client, org_id)
      {:ok, relationship} = ExPipedrive.OrganizationRelationships.get(client, relationship.id)
      {:ok, :ok} = ExPipedrive.OrganizationRelationships.delete(client, relationship.id)
  """

  alias ExPipedrive.Error
  alias ExPipedrive.OrganizationRelationship
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(org_id type rel_owner_org_id rel_linked_org_id)

  @doc """
  Lists all relationships for an organization via
  `GET /api/v1/organizationRelationships`.
  """
  @spec list(Client.t(), pos_integer()) ::
          {:ok, [OrganizationRelationship.t()]} | {:error, Error.t()}
  def list(%Client{} = client, org_id) do
    client
    |> Request.get("organizationRelationships", api_version: :v1, query: [org_id: org_id])
    |> Response.map([200], fn %{body: %{"data" => data}} ->
      data |> List.wrap() |> Enum.map(&OrganizationRelationship.new/1)
    end)
  end

  @doc """
  Fetches an organization relationship by id via
  `GET /api/v1/organizationRelationships/:id`.

  `org_id` is optional and scopes the calculated `rel_*` values to that
  organization's perspective.
  """
  @spec get(Client.t(), pos_integer(), pos_integer() | nil) ::
          {:ok, OrganizationRelationship.t()} | {:error, Error.t()}
  def get(%Client{} = client, id, org_id \\ nil) do
    query = if org_id, do: [org_id: org_id], else: []

    client
    |> Request.get("organizationRelationships/:id",
      api_version: :v1,
      query: query,
      opts: [path_params: [id: id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} -> OrganizationRelationship.new(data) end)
  end

  @doc """
  Creates an organization relationship via
  `POST /api/v1/organizationRelationships`.

  Accepts a map with `:type` (`"parent"` or `"related"`), `:rel_owner_org_id`,
  `:rel_linked_org_id`, and optional `:org_id`.
  """
  @spec create(Client.t(), map()) ::
          {:ok, OrganizationRelationship.t()} | {:error, Error.t()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    client
    |> Request.post(
      "organizationRelationships",
      WriteAttrs.take(attrs, @write_fields),
      api_version: :v1
    )
    |> Response.map([200, 201], fn %{body: %{"data" => data}} ->
      OrganizationRelationship.new(data)
    end)
  end

  @doc """
  Updates an organization relationship via
  `PUT /api/v1/organizationRelationships/:id`.
  """
  @spec update(Client.t(), pos_integer(), map()) ::
          {:ok, OrganizationRelationship.t()} | {:error, Error.t()}
  def update(%Client{} = client, id, attrs) when is_map(attrs) do
    client
    |> Request.put(
      "organizationRelationships/:id",
      WriteAttrs.take(attrs, @write_fields),
      api_version: :v1,
      opts: [path_params: [id: id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} -> OrganizationRelationship.new(data) end)
  end

  @doc """
  Deletes an organization relationship via
  `DELETE /api/v1/organizationRelationships/:id`.

  Returns `{:ok, :ok}`.
  """
  @spec delete(Client.t(), pos_integer()) :: {:ok, :ok} | {:error, Error.t()}
  def delete(%Client{} = client, id) do
    client
    |> Request.delete("organizationRelationships/:id",
      api_version: :v1,
      opts: [path_params: [id: id]]
    )
    |> Response.map([200], fn _env -> :ok end)
  end
end
