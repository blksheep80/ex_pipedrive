defmodule ExPipedrive.FakePipedriveServer do
  @moduledoc """
  Fake (yet also real HTTP) server to handle requests that conform to
  pipedrive's api and return responses that look like real pipedrive responses.
  """

  use Plug.Router

  import ExPipedrive.FakeActivityApiHandler
  import ExPipedrive.FakeActivityTypeApiHandler
  import ExPipedrive.FakeActivityV2ApiHandler
  import ExPipedrive.FakeDealApiHandler
  import ExPipedrive.FakeDealFieldApiHandler
  import ExPipedrive.FakeDealLabelApiHandler
  import ExPipedrive.FakeDealV2ApiHandler
  import ExPipedrive.FakeFieldV2ApiHandler
  import ExPipedrive.FakeFileApiHandler
  import ExPipedrive.FakeFilterApiHandler
  import ExPipedrive.FakeLeadApiHandler
  import ExPipedrive.FakeLeadLabelApiHandler
  import ExPipedrive.FakeNoteApiHandler
  import ExPipedrive.FakeOrganizationApiHandler
  import ExPipedrive.FakeOrganizationFieldApiHandler
  import ExPipedrive.FakeOrganizationLabelApiHandler
  import ExPipedrive.FakeOrganizationV2ApiHandler
  import ExPipedrive.FakePersonApiHandler
  import ExPipedrive.FakePersonFieldApiHandler
  import ExPipedrive.FakePersonLabelApiHandler
  import ExPipedrive.FakePersonV2ApiHandler
  import ExPipedrive.FakePipelineApiHandler
  import ExPipedrive.FakePipelineV2ApiHandler
  import ExPipedrive.FakeItemSearchV2ApiHandler
  import ExPipedrive.FakeProductV2ApiHandler
  import ExPipedrive.FakeProductVariationV2ApiHandler
  import ExPipedrive.FakeStageV2ApiHandler
  import ExPipedrive.FakeUserApiHandler
  import ExPipedrive.FakeWebhookApiHandler

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
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

  get "/api/v1/notes/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_note(conn.params)
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

  get "/api/v1/leadLabels" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_lead_labels()
  end

  post "/api/v1/leadLabels" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_create_lead_label()
  end

  patch "/api/v1/leadLabels/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_update_lead_label()
  end

  delete "/api/v1/leadLabels/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_delete_lead_label(conn.params)
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

  patch "/api/v1/leads/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_update_lead(conn.params)
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

  get "/api/v1/files" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_files(conn.query_params)
  end

  post "/api/v1/files/remote" do
    handle_create_remote_file(conn)
  end

  post "/api/v1/files/remoteLink" do
    handle_remote_link_file(conn)
  end

  post "/api/v1/files" do
    handle_upload_file(conn)
  end

  get "/api/v1/files/:id/download" do
    handle_download_file(conn, conn.params)
  end

  put "/api/v1/files/:id" do
    handle_update_file(conn)
  end

  delete "/api/v1/files/:id" do
    handle_delete_file(conn, conn.params)
  end

  get "/api/v1/files/:id" do
    handle_get_file(conn, conn.params)
  end

  get "/api/v1/filters" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_filters(conn.query_params)
  end

  post "/api/v1/filters" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_create_filter()
  end

  put "/api/v1/filters/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_update_filter()
  end

  delete "/api/v1/filters/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_delete_filter(conn.params)
  end

  get "/api/v1/filters/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_filter(conn.params)
  end

  get "/api/v1/users/me" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_me()
  end

  get "/api/v1/users/find" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_find_users(conn.query_params)
  end

  get "/api/v1/users/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_user(conn.params)
  end

  get "/api/v1/users" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_users(conn.query_params)
  end

  get "/api/v1/webhooks" do
    handle_list_webhooks(conn)
  end

  post "/api/v1/webhooks" do
    handle_create_webhook(conn)
  end

  delete "/api/v1/webhooks/:id" do
    handle_delete_webhook(conn, conn.params)
  end

  # --- API v2 (deals + persons + organizations + activities + pipelines + stages + products + search + fields) ---

  get "/api/v2/dealFields" do
    handle_list_fields_v2(conn, "deal", conn.query_params)
  end

  get "/api/v2/personFields" do
    handle_list_fields_v2(conn, "person", conn.query_params)
  end

  get "/api/v2/organizationFields" do
    handle_list_fields_v2(conn, "organization", conn.query_params)
  end

  get "/api/v2/dealFields/:field_code" do
    handle_get_deal_label_field(conn, conn.params)
  end

  post "/api/v2/dealFields/:field_code/options" do
    handle_add_deal_label_options(conn)
  end

  patch "/api/v2/dealFields/:field_code/options" do
    handle_update_deal_label_options(conn)
  end

  delete "/api/v2/dealFields/:field_code/options" do
    handle_delete_deal_label_options(conn)
  end

  get "/api/v2/personFields/:field_code" do
    handle_get_person_label_field(conn, conn.params)
  end

  post "/api/v2/personFields/:field_code/options" do
    handle_add_person_label_options(conn)
  end

  patch "/api/v2/personFields/:field_code/options" do
    handle_update_person_label_options(conn)
  end

  delete "/api/v2/personFields/:field_code/options" do
    handle_delete_person_label_options(conn)
  end

  get "/api/v2/organizationFields/:field_code" do
    handle_get_organization_label_field(conn, conn.params)
  end

  post "/api/v2/organizationFields/:field_code/options" do
    handle_add_organization_label_options(conn)
  end

  patch "/api/v2/organizationFields/:field_code/options" do
    handle_update_organization_label_options(conn)
  end

  delete "/api/v2/organizationFields/:field_code/options" do
    handle_delete_organization_label_options(conn)
  end

  get "/api/v2/itemSearch" do
    handle_item_search_v2(conn, conn.query_params)
  end

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

  get "/api/v2/activities" do
    handle_list_activities_v2(conn, conn.query_params)
  end

  post "/api/v2/activities" do
    handle_create_activity_v2(conn)
  end

  patch "/api/v2/activities/:id" do
    handle_update_activity_v2(conn)
  end

  delete "/api/v2/activities/:id" do
    handle_delete_activity_v2(conn, conn.params)
  end

  get "/api/v2/activities/:id" do
    handle_get_activity_v2(conn, conn.params)
  end

  get "/api/v2/pipelines" do
    handle_list_pipelines_v2(conn, conn.query_params)
  end

  post "/api/v2/pipelines" do
    handle_create_pipeline_v2(conn)
  end

  patch "/api/v2/pipelines/:id" do
    handle_update_pipeline_v2(conn)
  end

  delete "/api/v2/pipelines/:id" do
    handle_delete_pipeline_v2(conn, conn.params)
  end

  get "/api/v2/pipelines/:id" do
    handle_get_pipeline_v2(conn, conn.params)
  end

  get "/api/v2/stages" do
    handle_list_stages_v2(conn, conn.query_params)
  end

  post "/api/v2/stages" do
    handle_create_stage_v2(conn)
  end

  patch "/api/v2/stages/:id" do
    handle_update_stage_v2(conn)
  end

  delete "/api/v2/stages/:id" do
    handle_delete_stage_v2(conn, conn.params)
  end

  get "/api/v2/stages/:id" do
    handle_get_stage_v2(conn, conn.params)
  end

  get "/api/v2/products" do
    handle_list_products_v2(conn, conn.query_params)
  end

  post "/api/v2/products" do
    handle_create_product_v2(conn)
  end

  patch "/api/v2/products/:id" do
    handle_update_product_v2(conn)
  end

  delete "/api/v2/products/:id" do
    handle_delete_product_v2(conn, conn.params)
  end

  get "/api/v2/products/:id" do
    handle_get_product_v2(conn, conn.params)
  end

  get "/api/v2/products/:id/variations" do
    handle_list_product_variations_v2(conn, conn.params, conn.query_params)
  end

  post "/api/v2/products/:id/variations" do
    handle_create_product_variation_v2(conn)
  end

  patch "/api/v2/products/:id/variations/:variation_id" do
    handle_update_product_variation_v2(conn)
  end

  delete "/api/v2/products/:id/variations/:variation_id" do
    handle_delete_product_variation_v2(conn, conn.params)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
