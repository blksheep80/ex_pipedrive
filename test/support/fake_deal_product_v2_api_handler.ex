defmodule ExPipedrive.FakeDealProductV2ApiHandler do
  @moduledoc false

  import Plug.Conn

  @deal_product %{
    "id" => 3,
    "sum" => 90,
    "tax" => 0,
    "deal_id" => 1,
    "name" => "Mechanical Pencil",
    "product_id" => 1,
    "product_variation_id" => nil,
    "order_nr" => 50,
    "add_time" => "2019-12-19T11:36:49Z",
    "update_time" => "2019-12-19T11:36:49Z",
    "comments" => "",
    "currency" => "USD",
    "discount" => 0,
    "quantity" => 1,
    "item_price" => 90,
    "tax_method" => "inclusive",
    "discount_type" => "percentage",
    "is_enabled" => true,
    "billing_frequency" => "one-time",
    "billing_frequency_cycles" => nil,
    "billing_start_date" => "2019-12-19"
  }

  def handle_list_deal_products_v2(conn, %{"id" => "404"}, _query) do
    json_error(conn, 404, "Deal not found")
  end

  def handle_list_deal_products_v2(conn, %{"id" => deal_id}, _query) do
    {id, _} = Integer.parse(to_string(deal_id))

    json_ok(conn, %{
      "success" => true,
      "data" => [Map.put(@deal_product, "deal_id", id)],
      "additional_data" => %{"next_cursor" => nil}
    })
  end

  def handle_create_deal_product_v2(%{body_params: body, params: %{"id" => deal_id}} = conn) do
    {id, _} = Integer.parse(to_string(deal_id))

    data =
      @deal_product
      |> Map.merge(Map.take(body, Map.keys(@deal_product)))
      |> Map.put("deal_id", id)

    conn
    |> put_status(201)
    |> json_ok(%{"success" => true, "data" => data})
  end

  def handle_update_deal_product_v2(%{params: %{"attachment_id" => "404"}} = conn) do
    json_error(conn, 404, "Deal product not found")
  end

  def handle_update_deal_product_v2(
        %{body_params: body, params: %{"id" => deal_id, "attachment_id" => attachment_id}} = conn
      ) do
    {deal, _} = Integer.parse(to_string(deal_id))
    {att, _} = Integer.parse(to_string(attachment_id))

    data =
      @deal_product
      |> Map.merge(Map.take(body, Map.keys(@deal_product)))
      |> Map.put("deal_id", deal)
      |> Map.put("id", att)

    json_ok(conn, %{"success" => true, "data" => data})
  end

  def handle_delete_deal_product_v2(conn, %{"attachment_id" => "404"}) do
    json_error(conn, 404, "Deal product not found")
  end

  def handle_delete_deal_product_v2(conn, %{"attachment_id" => attachment_id}) do
    {att, _} = Integer.parse(to_string(attachment_id))
    json_ok(conn, %{"success" => true, "data" => %{"id" => att}})
  end

  def handle_delete_many_deal_products_v2(conn, %{"id" => "404"}, _query) do
    json_error(conn, 404, "Deal not found")
  end

  def handle_delete_many_deal_products_v2(conn, _params, query) do
    ids =
      case Map.get(query, "ids") do
        nil -> [3]
        "" -> [3]
        csv -> csv |> String.split(",") |> Enum.map(&String.to_integer/1)
      end

    json_ok(conn, %{
      "success" => true,
      "data" => %{"ids" => ids},
      "additional_data" => %{"more_items_in_collection" => false}
    })
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
