defmodule ExPipedrive.ErrorTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Error
  alias ExPipedrive.Response

  describe "from_env/1" do
    test "classifies auth, not-found, and rate-limit by status" do
      assert %Error{kind: :unauthorized, status: 401} =
               Error.from_env(env(401, %{"error" => "invalid token"}))

      assert %Error{kind: :not_found, status: 404, message: "Not Found"} =
               Error.from_env(env(404, %{"error" => "Not Found"}))

      assert %Error{kind: :rate_limited, status: 429} =
               Error.from_env(env(429, %{"error" => "rate limit"}))
    end

    test "classifies validation for other 4xx and api for 5xx" do
      assert %Error{kind: :validation, status: 400} =
               Error.from_env(env(400, %{"error" => "bad request"}))

      assert %Error{kind: :api, status: 500} =
               Error.from_env(env(500, %{"error" => "boom"}))
    end

    test "treats success:false bodies as api errors and keeps request id" do
      error =
        Error.from_env(
          env(200, %{"success" => false, "error" => "nope"}, [
            {"X-Request-Id", "req-123"},
            {"content-type", "application/json"}
          ])
        )

      assert error.kind == :api
      assert error.message == "nope"
      assert error.request_id == "req-123"
    end
  end

  describe "from_transport/1" do
    test "marks transport failures distinctly from API failures" do
      error = Error.from_transport(:econnrefused)

      assert error.kind == :transport
      assert error.reason == :econnrefused
      assert Error.transport?(error)
      refute Error.api?(error)
    end
  end

  describe "helpers" do
    test "rate_limited?/1 and unauthorized?/1 for easy pattern matching" do
      assert Error.rate_limited?(Error.from_env(env(429, %{})))
      assert Error.unauthorized?(Error.from_env(env(401, %{})))
      refute Error.rate_limited?(Error.from_env(env(404, %{})))
    end

    test "Exception.message/1 includes kind and status" do
      message = Exception.message(Error.from_env(env(404, %{"error" => "missing"})))
      assert message =~ "not_found"
      assert message =~ "404"
      assert message =~ "missing"
    end
  end

  describe "Response.map/3" do
    test "returns ok value on success statuses" do
      assert {:ok, :deal} =
               Response.map({:ok, env(200, %{"data" => %{}})}, [200], fn _ -> :deal end)
    end

    test "maps HTTP failures to Error structs" do
      assert {:error, %Error{kind: :not_found, status: 404}} =
               Response.map({:ok, env(404, %{"error" => "gone"})}, [200], fn _ -> :deal end)
    end

    test "maps success:false on an otherwise successful status to Error" do
      assert {:error, %Error{kind: :api, message: "nope"}} =
               Response.map(
                 {:ok, env(200, %{"success" => false, "error" => "nope"})},
                 [200],
                 fn _ -> :deal end
               )
    end

    test "maps transport failures to Error" do
      assert {:error, %Error{kind: :transport, reason: :timeout}} =
               Response.map({:error, :timeout}, [200], fn _ -> :deal end)
    end
  end

  defp env(status, body, headers \\ []) do
    %Tesla.Env{status: status, body: body, headers: headers, method: :get, url: "/"}
  end
end
