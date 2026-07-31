defmodule ExPipedrive.FakeUserApiHandler do
  @moduledoc false

  import Plug.Conn

  def handle_get_me(conn) do
    response_body = ~s"""
    {
      "success": true,
      "data": {
        "id": 123,
        "name": "Test User",
        "email": "test@example.com",
        "active_flag": true
      }
    }
    """

    conn
    |> send_resp(200, response_body)
  end

  def handle_get_user(conn, %{"id" => "123"}) do
    response_body = ~s"""
    {
      "success": true,
      "data": {
        "id": 123,
        "name": "Test User",
        "email": "test@example.com",
        "active_flag": true
      }
    }
    """

    conn
    |> send_resp(200, response_body)
  end

  def handle_get_user(conn, %{"id" => "404"}) do
    response_body = ~s"""
    {
      "success": false,
      "error": "User not found"
    }
    """

    conn
    |> send_resp(404, response_body)
  end

  def handle_list_users(conn, params \\ %{}) do
    start = Map.get(params, "start", "0") |> String.to_integer()
    limit = Map.get(params, "limit", "100") |> String.to_integer()

    response_body = ~s"""
    {
      "success": true,
      "data": [
        {
          "id": 123,
          "name": "Test User",
          "email": "test@example.com",
          "active_flag": true
        },
        {
          "id": 124,
          "name": "Second User",
          "email": "second@example.com",
          "active_flag": true
        }
      ],
      "additional_data": {
        "pagination": {
          "start": #{start},
          "limit": #{limit},
          "more_items_in_collection": false
        }
      }
    }
    """

    conn
    |> send_resp(200, response_body)
  end

  def handle_find_users(conn, %{"term" => "Test"} = params) do
    email_matches? = Map.get(params, "search_by_email") == "1"

    data =
      if email_matches? do
        """
        [
          {
            "id": 123,
            "name": "Test User",
            "email": "test@example.com",
            "active_flag": true
          }
        ]
        """
      else
        """
        [
          {
            "id": 123,
            "name": "Test User",
            "email": "test@example.com",
            "active_flag": true
          },
          {
            "id": 124,
            "name": "Test Other User",
            "email": "test.other@example.com",
            "active_flag": true
          }
        ]
        """
      end

    response_body = ~s"""
    {
      "success": true,
      "data": #{data}
    }
    """

    conn
    |> send_resp(200, response_body)
  end

  def handle_find_users(conn, _params) do
    response_body = ~s"""
    {
      "success": true,
      "data": []
    }
    """

    conn
    |> send_resp(200, response_body)
  end
end
