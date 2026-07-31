defmodule ExPipedrive.FakeOrganizationRelationshipApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V1OrganizationRelationships

  def handle_list_organization_relationships(conn, %{"org_id" => org_id}) do
    json_ok(conn, V1OrganizationRelationships.list_response(String.to_integer(org_id)))
  end

  def handle_get_organization_relationship(conn, %{"id" => id}) do
    json_ok(conn, V1OrganizationRelationships.get_response(String.to_integer(id)))
  end

  def handle_create_organization_relationship(%{body_params: attrs} = conn) do
    json_ok(conn, 201, V1OrganizationRelationships.create_response(attrs))
  end

  def handle_update_organization_relationship(%{body_params: attrs} = conn, %{"id" => id}) do
    json_ok(conn, V1OrganizationRelationships.update_response(String.to_integer(id), attrs))
  end

  def handle_delete_organization_relationship(conn, %{"id" => id}) do
    json_ok(conn, V1OrganizationRelationships.delete_response(String.to_integer(id)))
  end

  defp json_ok(conn, body), do: json_ok(conn, 200, body)

  defp json_ok(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(status, Jason.encode!(body))
  end
end
