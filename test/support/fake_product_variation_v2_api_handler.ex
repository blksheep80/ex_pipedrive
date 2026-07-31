defmodule ExPipedrive.FakeProductVariationV2ApiHandler do
  @moduledoc false

  import Plug.Conn

  alias ExPipedrive.Fixtures.V2ProductVariations

  def handle_list_product_variations_v2(conn, %{"id" => "404"}, _query) do
    json_error(conn, 404, "Product not found")
  end

  def handle_list_product_variations_v2(conn, %{"id" => id}, query) do
    case Map.get(query, "error") do
      "400" -> json_error(conn, 400, "bad request")
      "401" -> json_error(conn, 401, "unauthorized")
      "429" -> json_error(conn, 429, "rate limit exceeded")
      _ -> json_ok(conn, V2ProductVariations.list_response(id, Map.get(query, "cursor")))
    end
  end

  def handle_create_product_variation_v2(%{body_params: body, params: %{"id" => id}} = conn) do
    conn
    |> put_status(201)
    |> json_ok(V2ProductVariations.create_response(id, body))
  end

  def handle_update_product_variation_v2(%{params: %{"variation_id" => "404"}} = conn) do
    json_error(conn, 404, "Product variation not found")
  end

  def handle_update_product_variation_v2(
        %{body_params: body, params: %{"id" => id, "variation_id" => variation_id}} = conn
      ) do
    {int, ""} = Integer.parse(variation_id)
    json_ok(conn, V2ProductVariations.update_response(id, int, body))
  end

  def handle_delete_product_variation_v2(conn, %{"variation_id" => "404"}) do
    json_error(conn, 404, "Product variation not found")
  end

  def handle_delete_product_variation_v2(conn, %{"variation_id" => variation_id}) do
    case Integer.parse(variation_id) do
      {int, ""} -> json_ok(conn, V2ProductVariations.delete_response(int))
      _ -> json_error(conn, 400, "invalid product variation id")
    end
  end

  defp json_ok(conn, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> put_resp_header("x-request-id", "fake-product-variation-v2")
    |> send_resp(conn.status || 200, Jason.encode!(body))
  end

  defp json_error(conn, status, message) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> put_resp_header("x-request-id", "fake-product-variation-v2-error")
    |> send_resp(status, Jason.encode!(V2ProductVariations.error_response(status, message)))
  end
end
