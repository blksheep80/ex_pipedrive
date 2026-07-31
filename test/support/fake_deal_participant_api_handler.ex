defmodule ExPipedrive.FakeDealParticipantApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V1DealParticipants

  def handle_list_deal_participants(conn, %{"id" => id}) do
    json_ok(conn, V1DealParticipants.list_response(String.to_integer(id)))
  end

  def handle_add_deal_participant(%{body_params: %{"person_id" => person_id}} = conn, %{
        "id" => id
      }) do
    json_ok(conn, V1DealParticipants.add_response(String.to_integer(id), person_id))
  end

  def handle_delete_deal_participant(conn, %{
        "id" => id,
        "deal_participant_id" => deal_participant_id
      }) do
    json_ok(
      conn,
      V1DealParticipants.delete_response(
        String.to_integer(id),
        String.to_integer(deal_participant_id)
      )
    )
  end

  defp json_ok(conn, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(200, Jason.encode!(body))
  end
end
