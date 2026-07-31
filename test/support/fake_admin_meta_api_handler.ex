defmodule ExPipedrive.FakeAdminMetaApiHandler do
  @moduledoc false

  import Plug.Conn

  @currencies [
    %{
      "id" => 1,
      "code" => "EUR",
      "name" => "Euro",
      "decimal_points" => 2,
      "symbol" => "€",
      "active_flag" => true,
      "is_custom_flag" => false
    },
    %{
      "id" => 2,
      "code" => "USD",
      "name" => "US Dollar",
      "decimal_points" => 2,
      "symbol" => "$",
      "active_flag" => true,
      "is_custom_flag" => false
    }
  ]

  @permission_set_id "f07d229d-088a-4144-a40f-1fe64295d180"

  @permission_set %{
    "id" => @permission_set_id,
    "name" => "Deals regular user",
    "description" => "Access to sales data",
    "app" => "sales",
    "type" => "regular",
    "assignment_count" => 3,
    "contents" => ["can_add_products", "can_see_other_users"]
  }

  @role %{
    "id" => 2,
    "parent_role_id" => 1,
    "name" => "Admins",
    "active_flag" => true,
    "assignment_count" => "1",
    "sub_role_count" => "1",
    "level" => 1
  }

  @team %{
    "id" => 1,
    "name" => "Closers",
    "description" => "Berlin office Sales Team",
    "manager_id" => 4,
    "users" => [2, 3, 4, 5],
    "active_flag" => 1,
    "deleted_flag" => 0,
    "add_time" => "2019-10-07 09:06:09",
    "created_by_user_id" => 2
  }

  def handle_list_currencies(conn, params) do
    data =
      case Map.get(params, "term") do
        nil ->
          @currencies

        "" ->
          @currencies

        term ->
          down = String.downcase(term)

          Enum.filter(@currencies, fn c ->
            String.contains?(String.downcase(c["name"]), down) or
              String.contains?(String.downcase(c["code"]), down)
          end)
      end

    json(conn, 200, %{"success" => true, "data" => data})
  end

  def handle_list_recents(conn, params) do
    case Map.get(params, "since_timestamp") do
      nil ->
        json(conn, 400, %{"success" => false, "error" => "since_timestamp is required"})

      _since ->
        item_filter = Map.get(params, "items")

        data = [
          %{
            "item" => "deal",
            "id" => 10,
            "data" => %{"id" => 10, "title" => "Recent deal", "status" => "open"}
          },
          %{
            "item" => "person",
            "id" => 20,
            "data" => %{"id" => 20, "name" => "Ada Lovelace"}
          }
        ]

        data =
          if is_binary(item_filter) and item_filter != "" do
            allowed = String.split(item_filter, ",")
            Enum.filter(data, &(&1["item"] in allowed))
          else
            data
          end

        json(conn, 200, %{
          "success" => true,
          "data" => data,
          "additional_data" => %{
            "pagination" => %{
              "start" => 0,
              "limit" => 100,
              "more_items_in_collection" => false
            }
          }
        })
    end
  end

  def handle_list_roles(conn) do
    json(conn, 200, %{
      "success" => true,
      "data" => [
        %{
          "id" => 1,
          "parent_role_id" => nil,
          "name" => "(Unassigned users)",
          "active_flag" => true,
          "assignment_count" => "0",
          "sub_role_count" => "0",
          "level" => 1
        },
        @role
      ]
    })
  end

  def handle_get_role(conn, %{"id" => "2"}) do
    json(conn, 200, %{
      "success" => true,
      "data" => @role,
      "additional_data" => %{"settings" => %{"deal_default_visibility" => 3}}
    })
  end

  def handle_get_role(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Role not found"})
  end

  def handle_list_role_assignments(conn, %{"id" => "2"}) do
    json(conn, 200, %{
      "success" => true,
      "data" => [
        %{
          "user_id" => 1_234_567,
          "role_id" => 2,
          "parent_role_id" => 1,
          "name" => "Admins",
          "active_flag" => true,
          "type" => "user"
        }
      ],
      "additional_data" => %{
        "pagination" => %{"start" => 0, "limit" => 100, "more_items_in_collection" => false}
      }
    })
  end

  def handle_list_role_pipelines(conn, %{"id" => "2"}) do
    json(conn, 200, %{"success" => true, "data" => %{"1" => true, "2" => false}})
  end

  def handle_list_role_settings(conn, %{"id" => "2"}) do
    json(conn, 200, %{
      "success" => true,
      "data" => %{"deal_default_visibility" => 3, "person_default_visibility" => 3}
    })
  end

  def handle_list_permission_sets(conn, params) do
    data =
      case Map.get(params, "app") do
        "sales" -> [@permission_set]
        nil -> [@permission_set]
        _ -> []
      end

    json(conn, 200, %{"success" => true, "data" => data})
  end

  def handle_get_permission_set(conn, %{"id" => @permission_set_id}) do
    json(conn, 200, %{"success" => true, "data" => @permission_set})
  end

  def handle_get_permission_set(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Permission set not found"})
  end

  def handle_list_permission_set_assignments(conn, %{"id" => @permission_set_id}) do
    json(conn, 200, %{
      "success" => true,
      "data" => [%{"id" => 1, "user_id" => 42, "permission_set_id" => @permission_set_id}],
      "additional_data" => %{
        "pagination" => %{"start" => 0, "limit" => 100, "more_items_in_collection" => false}
      }
    })
  end

  def handle_list_teams(conn, _params) do
    json(conn, 200, %{"success" => true, "data" => [@team]})
  end

  def handle_get_team(conn, %{"id" => "1"}) do
    json(conn, 200, %{"success" => true, "data" => @team})
  end

  def handle_get_team(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "Team not found"})
  end

  def handle_list_team_users(conn, %{"id" => "1"}) do
    json(conn, 200, %{"success" => true, "data" => [2, 3, 4, 5]})
  end

  def handle_list_user_teams(conn, %{"id" => "5"}) do
    json(conn, 200, %{"success" => true, "data" => [@team]})
  end

  def handle_list_user_teams(conn, %{"id" => _}) do
    json(conn, 200, %{"success" => true, "data" => []})
  end

  defp json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(status, Jason.encode!(body))
  end
end
