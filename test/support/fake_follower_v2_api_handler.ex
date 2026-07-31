defmodule ExPipedrive.FakeFollowerV2ApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V2Followers

  def handle_list_followers_v2(conn, segment, %{"id" => id}) do
    entity_id = String.to_integer(id)
    json_ok(conn, V2Followers.list_response(segment, entity_id, [{1, 456}, {2, 789}]))
  end

  def handle_add_follower_v2(%{body_params: %{"user_id" => user_id}} = conn, segment, %{
        "id" => id
      }) do
    entity_id = String.to_integer(id)
    json_ok(conn, 201, V2Followers.add_response(segment, entity_id, 3, user_id))
  end

  def handle_delete_follower_v2(conn, segment, %{"id" => id, "follower_id" => follower_id}) do
    entity_id = String.to_integer(id)

    json_ok(
      conn,
      V2Followers.delete_response(segment, entity_id, String.to_integer(follower_id), 456)
    )
  end

  defp json_ok(conn, body), do: json_ok(conn, 200, body)

  defp json_ok(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(status, Jason.encode!(body))
  end
end
