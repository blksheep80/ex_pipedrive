defmodule ExPipedrive.FakeFilterApiHandler do
  @moduledoc false

  import Plug.Conn

  @conditions %{
    "glue" => "and",
    "conditions" => [
      %{
        "glue" => "and",
        "conditions" => [
          %{
            "object" => "deal",
            "field_id" => 12_456,
            "operator" => ">",
            "value" => 1000,
            "extra_value" => nil
          }
        ]
      },
      %{"glue" => "or", "conditions" => []}
    ]
  }

  @filter %{
    "id" => 1,
    "name" => "High value deals",
    "active_flag" => true,
    "type" => "deals",
    "temporary_flag" => false,
    "user_id" => 17_120_881,
    "add_time" => "2023-01-23 19:42:58",
    "update_time" => "2023-01-23 19:42:58",
    "visible_to" => "3",
    "custom_view_id" => nil,
    "conditions" => @conditions
  }

  def handle_list_filters(conn, params \\ %{}) do
    data =
      case Map.get(params, "type") do
        "leads" -> []
        _ -> [@filter]
      end

    json(conn, 200, %{"success" => true, "data" => data})
  end

  def handle_get_filter(conn, %{"id" => "1"}) do
    json(conn, 200, %{"success" => true, "data" => @filter})
  end

  def handle_get_filter(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Filter not found"})
  end

  def handle_create_filter(%{body_params: %{"name" => name} = body} = conn) do
    filter =
      @filter
      |> Map.merge(body)
      |> Map.put("name", name)

    json(conn, 201, %{"success" => true, "data" => filter})
  end

  def handle_update_filter(%{body_params: body, params: %{"id" => "1"}} = conn) do
    filter = Map.merge(@filter, body)

    json(conn, 200, %{"success" => true, "data" => filter})
  end

  def handle_update_filter(%{params: %{"id" => "404"}} = conn) do
    json(conn, 404, %{"success" => false, "error" => "Filter not found"})
  end

  def handle_delete_filter(conn, %{"id" => "1"}) do
    json(conn, 200, %{"success" => true, "data" => %{"id" => 1}})
  end

  def handle_delete_filter(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Filter not found"})
  end

  defp json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(status, Jason.encode!(body))
  end
end
