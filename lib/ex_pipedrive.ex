defmodule ExPipedrive do
  @moduledoc """
  This is the entrypoint for making requests to pipedrive via ExPipedrive.
  """

  use Tesla

  defdelegate add_activity(client, activity), to: ExPipedrive.Activities
  defdelegate add_note(client, note), to: ExPipedrive.Notes
  defdelegate create_lead(client, lead), to: ExPipedrive.Leads
  defdelegate create_organization(client, org), to: ExPipedrive.Organizations
  defdelegate create_person(client, person), to: ExPipedrive.Persons
  defdelegate find_users_by_name(client, term, opts \\ []), to: ExPipedrive.Users
  defdelegate get_all_org_notes(client, org_id, opts), to: ExPipedrive.Notes
  defdelegate get_deal(client, deal_id), to: ExPipedrive.Deals
  defdelegate get_lead(client, lead_id), to: ExPipedrive.Leads
  defdelegate get_organization(client, org_id), to: ExPipedrive.Organizations
  defdelegate get_person(client, person_id), to: ExPipedrive.Persons
  defdelegate list_activities(client, opts \\ []), to: ExPipedrive.Activities
  defdelegate list_activity_types(client), to: ExPipedrive.ActivityTypes
  defdelegate list_deals(client, opts), to: ExPipedrive.Deals
  defdelegate list_deal_fields(client, opts), to: ExPipedrive.DealFields
  defdelegate list_leads(client, opts \\ []), to: ExPipedrive.Leads
  defdelegate list_notes(client, opts \\ []), to: ExPipedrive.Notes
  defdelegate list_organizations(client, opts), to: ExPipedrive.Organizations
  defdelegate list_organization_fields(client, opts), to: ExPipedrive.OrganizationFields
  defdelegate list_own_activities(client, opts \\ []), to: ExPipedrive.Activities
  defdelegate list_person_fields(client, opts), to: ExPipedrive.PersonFields
  defdelegate list_persons(client, opts), to: ExPipedrive.Persons
  defdelegate list_pipeline_deals(client, pipeline_id), to: ExPipedrive.Pipelines
  defdelegate list_pipelines(client), to: ExPipedrive.Pipelines
  defdelegate search_deals(client, term, opts), to: ExPipedrive.Deals
  defdelegate search_leads(client, term, opts), to: ExPipedrive.Leads
  defdelegate search_organizations(client, term, opts), to: ExPipedrive.Organizations
  defdelegate search_persons(client, term, opts), to: ExPipedrive.Persons
  defdelegate update_organization(client, org_id, data), to: ExPipedrive.Organizations

  def client(api_token, base_url) do
    base_url = process_base(base_url)

    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.JSON, engine: Jason},
      {Tesla.Middleware.Query, api_token: api_token},
      Tesla.Middleware.PathParams
    ]

    Tesla.client(middleware)
  end

  def build_client(refresh_token, client_id, client_secret, base_url) do
    base_url = process_base(base_url)

    case ExPipedrive.Oauth.refresh_access_token(refresh_token, client_id, client_secret) do
      {:ok, access_token} ->
        middleware = [
          {Tesla.Middleware.BaseUrl, base_url},
          {Tesla.Middleware.BearerAuth, token: access_token},
          {Tesla.Middleware.JSON, engine: Jason},
          Tesla.Middleware.PathParams
        ]

        {:ok, Tesla.client(middleware)}

      {:error, error} ->
        {:error, error}
    end
  end

  defp process_base(base_url) do
    if Regex.match?(~r/^https?:\/\//i, base_url) do
      base_url
    else
      "https://" <> base_url
    end
  end
end
