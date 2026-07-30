defmodule ExPipedrive.FakePipedriveServer do
  @moduledoc """
  Fake (yet also real HTTP) server to handle requests that conform to
  pipedrive's api and return responses that look like real pipedrive responses.
  """

  use Plug.Router

  import ExPipedrive.FakeActivityApiHandler
  import ExPipedrive.FakeActivityTypeApiHandler
  import ExPipedrive.FakeDealApiHandler
  import ExPipedrive.FakeDealFieldApiHandler
  import ExPipedrive.FakeDealV2ApiHandler
  import ExPipedrive.FakeLeadApiHandler
  import ExPipedrive.FakeNoteApiHandler
  import ExPipedrive.FakeOrganizationApiHandler
  import ExPipedrive.FakeOrganizationFieldApiHandler
  import ExPipedrive.FakeOrganizationV2ApiHandler
  import ExPipedrive.FakePersonApiHandler
  import ExPipedrive.FakePersonFieldApiHandler
  import ExPipedrive.FakePersonV2ApiHandler
  import ExPipedrive.FakePipelineApiHandler

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/api/v1/activities" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_add_activity()
  end

  get "/api/v1/activityTypes" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_activity_types()
  end

  get "/api/v1/deals" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_deals(conn.query_params)
  end

  get "/api/v1/dealFields" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_deal_fields()
  end

  get "/api/v1/deals/search" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_search_deals(conn.query_params)
  end

  get "/api/v1/deals/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_deal(conn.params)
  end

  post "/api/v1/notes" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_add_note()
  end

  get "/api/v1/notes" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_notes(conn.query_params)
  end

  get "/api/v1/organizationFields/" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_org_field_keys_and_names(conn.params)
  end

  get "/api/v1/organizations" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_organizations(conn.query_params)
  end

  get "/api/v1/organizations/search" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_search_organizations(conn.query_params)
  end

  get "/api/v1/organizations/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_organization(conn.params)
  end

  put "/api/v1/organizations/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_update_organization()
  end

  post "/api/v1/organizations" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_create_organization()
  end

  get "/api/v1/persons" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_persons()
  end

  post "/api/v1/persons" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_create_person()
  end

  get "/api/v1/persons/search" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_search_persons(conn.query_params)
  end

  get "/api/v1/persons/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_person(conn.params)
  end

  get "/api/v1/personFields" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_person_fields()
  end

  get "/api/v1/pipelines/:id/deals" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_pipeline_deals(conn.query_params)
  end

  get "/api/v1/pipelines" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_pipelines()
  end

  get "/api/v1/leads" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_leads(conn.query_params)
  end

  post "/api/v1/leads" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_create_lead()
  end

  get "/api/v1/leads/search" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_search_leads(conn.query_params)
  end

  get "/api/v1/leads/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_lead(conn.params)
  end

  get "/api/v1/activities/collection" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_activities()
  end

  get "/api/v1/activities" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_own_activities()
  end

  # --- API v2 (deals + persons + organizations) ---

  get "/api/v2/deals" do
    handle_list_deals_v2(conn, conn.query_params)
  end

  post "/api/v2/deals" do
    handle_create_deal_v2(conn)
  end

  patch "/api/v2/deals/:id" do
    handle_update_deal_v2(conn)
  end

  delete "/api/v2/deals/:id" do
    handle_delete_deal_v2(conn, conn.params)
  end

  get "/api/v2/deals/:id" do
    handle_get_deal_v2(conn, conn.params)
  end

  get "/api/v2/persons" do
    handle_list_persons_v2(conn, conn.query_params)
  end

  post "/api/v2/persons" do
    handle_create_person_v2(conn)
  end

  patch "/api/v2/persons/:id" do
    handle_update_person_v2(conn)
  end

  get "/api/v2/persons/:id" do
    handle_get_person_v2(conn, conn.params)
  end

  get "/api/v2/organizations" do
    handle_list_organizations_v2(conn, conn.query_params)
  end

  post "/api/v2/organizations" do
    handle_create_organization_v2(conn)
  end

  patch "/api/v2/organizations/:id" do
    handle_update_organization_v2(conn)
  end

  delete "/api/v2/organizations/:id" do
    handle_delete_organization_v2(conn, conn.params)
  end

  get "/api/v2/organizations/:id" do
    handle_get_organization_v2(conn, conn.params)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
