defmodule ExPipedrive.Labels do
  @moduledoc """
  Facade over Pipedrive label definitions for deals, persons, organizations,
  and leads.

  Pipedrive models labels two different ways:

  - **Deals / Persons / Organizations** — labels are option values on the
    system `label_ids` field. There is no dedicated `dealLabels` /
    `personLabels` / `organizationLabels` endpoint; label definitions are
    listed and managed via the API v2 field-options endpoints
    (`ExPipedrive.DealLabels`, `ExPipedrive.PersonLabels`,
    `ExPipedrive.OrganizationLabels`).
  - **Leads** — labels have a dedicated API v1 `/leadLabels` endpoint
    (`ExPipedrive.LeadLabels`).

  This module simply delegates to those per-entity modules so callers can
  reach for one place when working across entity types; prefer the
  entity-specific module directly when you only need one.

  ## Assigning labels to an entity

  Assigning or clearing labels on a deal, person, organization, or lead is
  **not** a separate endpoint — set the `label_ids` attribute (a list of
  label ids) when calling that entity's own `update/3` (e.g.
  `ExPipedrive.Deals.update/3`, `ExPipedrive.Persons.update/3`).
  """

  alias ExPipedrive.DealLabels
  alias ExPipedrive.Error
  alias ExPipedrive.Label
  alias ExPipedrive.LeadLabels
  alias ExPipedrive.OrganizationLabels
  alias ExPipedrive.PersonLabels
  alias Tesla.Client

  @doc "Lists deal label definitions. See `ExPipedrive.DealLabels.list/1`."
  @spec list_deal_labels(Client.t()) :: {:ok, [Label.t()]} | {:error, Error.t()}
  def list_deal_labels(%Client{} = client), do: DealLabels.list(client)

  @doc "Creates a deal label. See `ExPipedrive.DealLabels.create/2`."
  @spec create_deal_label(Client.t(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def create_deal_label(%Client{} = client, attrs), do: DealLabels.create(client, attrs)

  @doc "Updates a deal label. See `ExPipedrive.DealLabels.update/3`."
  @spec update_deal_label(Client.t(), term(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def update_deal_label(%Client{} = client, id, attrs), do: DealLabels.update(client, id, attrs)

  @doc "Deletes a deal label. See `ExPipedrive.DealLabels.delete/2`."
  @spec delete_deal_label(Client.t(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def delete_deal_label(%Client{} = client, id), do: DealLabels.delete(client, id)

  @doc "Lists person label definitions. See `ExPipedrive.PersonLabels.list/1`."
  @spec list_person_labels(Client.t()) :: {:ok, [Label.t()]} | {:error, Error.t()}
  def list_person_labels(%Client{} = client), do: PersonLabels.list(client)

  @doc "Creates a person label. See `ExPipedrive.PersonLabels.create/2`."
  @spec create_person_label(Client.t(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def create_person_label(%Client{} = client, attrs), do: PersonLabels.create(client, attrs)

  @doc "Updates a person label. See `ExPipedrive.PersonLabels.update/3`."
  @spec update_person_label(Client.t(), term(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def update_person_label(%Client{} = client, id, attrs),
    do: PersonLabels.update(client, id, attrs)

  @doc "Deletes a person label. See `ExPipedrive.PersonLabels.delete/2`."
  @spec delete_person_label(Client.t(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def delete_person_label(%Client{} = client, id), do: PersonLabels.delete(client, id)

  @doc """
  Lists organization label definitions. See
  `ExPipedrive.OrganizationLabels.list/1`.
  """
  @spec list_organization_labels(Client.t()) :: {:ok, [Label.t()]} | {:error, Error.t()}
  def list_organization_labels(%Client{} = client), do: OrganizationLabels.list(client)

  @doc """
  Creates an organization label. See
  `ExPipedrive.OrganizationLabels.create/2`.
  """
  @spec create_organization_label(Client.t(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def create_organization_label(%Client{} = client, attrs),
    do: OrganizationLabels.create(client, attrs)

  @doc """
  Updates an organization label. See
  `ExPipedrive.OrganizationLabels.update/3`.
  """
  @spec update_organization_label(Client.t(), term(), term()) ::
          {:ok, Label.t()} | {:error, Error.t()}
  def update_organization_label(%Client{} = client, id, attrs),
    do: OrganizationLabels.update(client, id, attrs)

  @doc """
  Deletes an organization label. See
  `ExPipedrive.OrganizationLabels.delete/2`.
  """
  @spec delete_organization_label(Client.t(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def delete_organization_label(%Client{} = client, id),
    do: OrganizationLabels.delete(client, id)

  @doc "Lists lead label definitions. See `ExPipedrive.LeadLabels.list/1`."
  @spec list_lead_labels(Client.t()) :: {:ok, [Label.t()]} | {:error, Error.t()}
  def list_lead_labels(%Client{} = client), do: LeadLabels.list(client)

  @doc "Creates a lead label. See `ExPipedrive.LeadLabels.create/2`."
  @spec create_lead_label(Client.t(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def create_lead_label(%Client{} = client, attrs), do: LeadLabels.create(client, attrs)

  @doc "Updates a lead label. See `ExPipedrive.LeadLabels.update/3`."
  @spec update_lead_label(Client.t(), term(), term()) :: {:ok, Label.t()} | {:error, Error.t()}
  def update_lead_label(%Client{} = client, id, attrs), do: LeadLabels.update(client, id, attrs)

  @doc "Deletes a lead label. See `ExPipedrive.LeadLabels.delete/2`."
  @spec delete_lead_label(Client.t(), term()) :: {:ok, term()} | {:error, Error.t()}
  def delete_lead_label(%Client{} = client, id), do: LeadLabels.delete(client, id)
end
