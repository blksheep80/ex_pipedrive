defmodule ExPipedrive.FakeWebhookApiHandler do
  @moduledoc false

  import Plug.Conn

  @subscription %{
    "id" => 42,
    "subscription_url" => "https://example.test/pipedrive/webhooks",
    "event_action" => "change",
    "event_object" => "deal",
    "name" => "Deal changes",
    "user_id" => 7,
    "company_id" => 11,
    "version" => "2.0",
    "http_auth_user" => "pipedrive",
    "is_active" => true,
    "add_time" => "2026-07-30 12:00:00"
  }

  def handle_list_webhooks(conn) do
    json(conn, 200, %{"success" => true, "data" => [@subscription]})
  end

  def handle_create_webhook(
        %{body_params: %{"subscription_url" => subscription_url} = body} = conn
      ) do
    subscription =
      @subscription
      |> Map.merge(body)
      |> Map.put("subscription_url", subscription_url)

    json(conn, 201, %{"success" => true, "data" => subscription})
  end

  def handle_delete_webhook(conn, %{"id" => "42"}) do
    json(conn, 200, %{"success" => true, "data" => nil})
  end

  def handle_delete_webhook(conn, _params) do
    json(conn, 404, %{"success" => false, "error" => "Webhook not found"})
  end

  defp json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(status, Jason.encode!(body))
  end
end
