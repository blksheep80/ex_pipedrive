defmodule ExPipedrive.FakePipedriveServer do
  @moduledoc """
  Fake (yet also real HTTP) server to handle requests that conform to
  pipedrive's api and return responses that look like real pipedrive responses.
  """

  use Plug.Router

  import ExPipedrive.FakeActivityApiHandler
  import ExPipedrive.FakeActivityTypeApiHandler
  import ExPipedrive.FakeActivityV2ApiHandler
  import ExPipedrive.FakeAdminMetaApiHandler
  import ExPipedrive.FakeCallLogApiHandler
  import ExPipedrive.FakeDealApiHandler
  import ExPipedrive.FakeDealFieldApiHandler
  import ExPipedrive.FakeDealLabelApiHandler
  import ExPipedrive.FakeDealInstallmentV2ApiHandler
  import ExPipedrive.FakeDealParticipantApiHandler
  import ExPipedrive.FakeDealProductV2ApiHandler
  import ExPipedrive.FakeDealV2ApiHandler
  import ExPipedrive.FakeFieldV2ApiHandler
  import ExPipedrive.FakeFileApiHandler
  import ExPipedrive.FakeFilterApiHandler
  import ExPipedrive.FakeFollowerV2ApiHandler
  import ExPipedrive.FakeGoalApiHandler
  import ExPipedrive.FakeLeadApiHandler
  import ExPipedrive.FakeLeadLabelApiHandler
  import ExPipedrive.FakeMailboxApiHandler
  import ExPipedrive.FakeNoteApiHandler
  import ExPipedrive.FakeOrganizationApiHandler
  import ExPipedrive.FakeOrganizationFieldApiHandler
  import ExPipedrive.FakeOrganizationLabelApiHandler
  import ExPipedrive.FakeOrganizationRelationshipApiHandler
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

  post "/api/v1/activityTypes" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_create_activity_type()
  end

  put "/api/v1/activityTypes/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_update_activity_type()
  end

  delete "/api/v1/activityTypes/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_delete_activity_type(conn.params)
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

  get "/api/v1/deals/:id/participants" do
    handle_list_deal_participants(conn, conn.params)
  end

  post "/api/v1/deals/:id/participants" do
    handle_add_deal_participant(conn, conn.params)
  end

  delete "/api/v1/deals/:id/participants/:deal_participant_id" do
    handle_delete_deal_participant(conn, conn.params)
  end

  get "/api/v1/organizationRelationships" do
    handle_list_organization_relationships(conn, conn.query_params)
  end

  post "/api/v1/organizationRelationships" do
    handle_create_organization_relationship(conn)
  end

  put "/api/v1/organizationRelationships/:id" do
    handle_update_organization_relationship(conn, conn.params)
  end

  delete "/api/v1/organizationRelationships/:id" do
    handle_delete_organization_relationship(conn, conn.params)
  end

  get "/api/v1/organizationRelationships/:id" do
    handle_get_organization_relationship(conn, conn.params)
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

  get "/api/v1/callLogs" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_call_logs(conn.query_params)
  end

  post "/api/v1/callLogs" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_create_call_log()
  end

  post "/api/v1/callLogs/:id/recordings" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_add_call_log_recording()
  end

  delete "/api/v1/callLogs/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_delete_call_log(conn.params)
  end

  get "/api/v1/callLogs/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_call_log(conn.params)
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

  get "/api/v2/activityFields" do
    handle_list_fields_v2(conn, "activity", conn.query_params)
  end

  get "/api/v2/productFields" do
    handle_list_fields_v2(conn, "product", conn.query_params)
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

  get "/api/v2/deals/installments" do
    handle_list_deal_installments_v2(conn, conn.query_params)
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

  get "/api/v2/deals/:id/followers" do
    handle_list_followers_v2(conn, "deals", conn.params)
  end

  post "/api/v2/deals/:id/followers" do
    handle_add_follower_v2(conn, "deals", conn.params)
  end

  delete "/api/v2/deals/:id/followers/:follower_id" do
    handle_delete_follower_v2(conn, "deals", conn.params)
  end

  get "/api/v2/deals/:id/products" do
    handle_list_deal_products_v2(conn, conn.params, conn.query_params)
  end

  post "/api/v2/deals/:id/products" do
    handle_create_deal_product_v2(conn)
  end

  delete "/api/v2/deals/:id/products" do
    handle_delete_many_deal_products_v2(conn, conn.params, conn.query_params)
  end

  patch "/api/v2/deals/:id/products/:attachment_id" do
    handle_update_deal_product_v2(conn)
  end

  delete "/api/v2/deals/:id/products/:attachment_id" do
    handle_delete_deal_product_v2(conn, conn.params)
  end

  post "/api/v2/deals/:id/installments" do
    handle_create_deal_installment_v2(conn)
  end

  patch "/api/v2/deals/:id/installments/:installment_id" do
    handle_update_deal_installment_v2(conn)
  end

  delete "/api/v2/deals/:id/installments/:installment_id" do
    handle_delete_deal_installment_v2(conn, conn.params)
  end

  get "/api/v2/persons/:id/followers" do
    handle_list_followers_v2(conn, "persons", conn.params)
  end

  post "/api/v2/persons/:id/followers" do
    handle_add_follower_v2(conn, "persons", conn.params)
  end

  delete "/api/v2/persons/:id/followers/:follower_id" do
    handle_delete_follower_v2(conn, "persons", conn.params)
  end

  get "/api/v2/organizations/:id/followers" do
    handle_list_followers_v2(conn, "organizations", conn.params)
  end

  post "/api/v2/organizations/:id/followers" do
    handle_add_follower_v2(conn, "organizations", conn.params)
  end

  delete "/api/v2/organizations/:id/followers/:follower_id" do
    handle_delete_follower_v2(conn, "organizations", conn.params)
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

  get "/api/v1/mailbox/mailThreads" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_mail_threads(conn.query_params)
  end

  put "/api/v1/mailbox/mailThreads/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_update_mail_thread()
  end

  delete "/api/v1/mailbox/mailThreads/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_delete_mail_thread(conn.params)
  end

  get "/api/v1/mailbox/mailThreads/:id/mailMessages" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_mail_thread_messages(conn.params)
  end

  get "/api/v1/mailbox/mailThreads/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_mail_thread(conn.params)
  end

  get "/api/v1/mailbox/mailMessages/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_mail_message(conn.params)
  end

  get "/api/v1/goals/find" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_find_goals(conn.query_params)
  end

  post "/api/v1/goals" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_create_goal()
  end

  put "/api/v1/goals/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_update_goal()
  end

  delete "/api/v1/goals/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_delete_goal(conn.params)
  end

  get "/api/v1/goals/:id/results" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_goal_result(conn.params)
  end

  get "/api/v1/currencies" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_currencies(conn.query_params)
  end

  get "/api/v1/recents" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_recents(conn.query_params)
  end

  get "/api/v1/roles" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_roles()
  end

  get "/api/v1/roles/:id/assignments" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_role_assignments(conn.params)
  end

  get "/api/v1/roles/:id/pipelines" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_role_pipelines(conn.params)
  end

  get "/api/v1/roles/:id/settings" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_role_settings(conn.params)
  end

  get "/api/v1/roles/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_role(conn.params)
  end

  get "/api/v1/permissionSets" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_permission_sets(conn.query_params)
  end

  get "/api/v1/permissionSets/:id/assignments" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_permission_set_assignments(conn.params)
  end

  get "/api/v1/permissionSets/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_permission_set(conn.params)
  end

  get "/api/v1/legacyTeams" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_teams(conn.query_params)
  end

  get "/api/v1/legacyTeams/user/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_user_teams(conn.params)
  end

  get "/api/v1/legacyTeams/:id/users" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_list_team_users(conn.params)
  end

  get "/api/v1/legacyTeams/:id" do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> handle_get_team(conn.params)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
