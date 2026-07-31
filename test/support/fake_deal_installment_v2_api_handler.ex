defmodule ExPipedrive.FakeDealInstallmentV2ApiHandler do
  @moduledoc false

  import Plug.Conn

  @installment %{
    "id" => 1,
    "deal_id" => 1,
    "description" => "Delivery Fee",
    "amount" => 10,
    "billing_date" => "2025-03-10"
  }

  def handle_list_deal_installments_v2(conn, query) do
    case Map.get(query, "deal_ids") do
      "404" ->
        json_error(conn, 404, "Deal not found")

      deal_ids when is_binary(deal_ids) ->
        ids =
          deal_ids
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)

        data =
          Enum.map(ids, fn deal_id ->
            @installment
            |> Map.put("deal_id", deal_id)
            |> Map.put("id", deal_id)
          end)

        json_ok(conn, %{
          "success" => true,
          "data" => data,
          "additional_data" => %{"next_cursor" => nil}
        })

      _ ->
        json_error(conn, 400, "deal_ids is required")
    end
  end

  def handle_create_deal_installment_v2(%{body_params: body, params: %{"id" => deal_id}} = conn) do
    case deal_id do
      "404" ->
        json_error(conn, 404, "Deal not found")

      _ ->
        {id, _} = Integer.parse(to_string(deal_id))

        data =
          @installment
          |> Map.merge(Map.take(body, Map.keys(@installment)))
          |> Map.put("deal_id", id)

        conn
        |> put_status(200)
        |> json_ok(%{"success" => true, "data" => data})
    end
  end

  def handle_update_deal_installment_v2(%{params: %{"installment_id" => "404"}} = conn) do
    json_error(conn, 404, "Installment not found")
  end

  def handle_update_deal_installment_v2(
        %{body_params: body, params: %{"id" => deal_id, "installment_id" => installment_id}} =
          conn
      ) do
    {deal, _} = Integer.parse(to_string(deal_id))
    {inst, _} = Integer.parse(to_string(installment_id))

    data =
      @installment
      |> Map.merge(Map.take(body, Map.keys(@installment)))
      |> Map.put("deal_id", deal)
      |> Map.put("id", inst)

    json_ok(conn, %{"success" => true, "data" => data})
  end

  def handle_delete_deal_installment_v2(conn, %{"installment_id" => "404"}) do
    json_error(conn, 404, "Installment not found")
  end

  def handle_delete_deal_installment_v2(conn, %{"installment_id" => installment_id}) do
    {inst, _} = Integer.parse(to_string(installment_id))
    json_ok(conn, %{"success" => true, "data" => %{"id" => inst}})
  end

  defp json_ok(conn, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(conn.status || 200, Jason.encode!(body))
  end

  defp json_error(conn, status, message) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(status, Jason.encode!(%{"success" => false, "error" => message}))
  end
end
