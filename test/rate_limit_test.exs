defmodule ExPipedrive.RateLimitTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.RateLimit

  test "parses ratelimit and daily headers" do
    headers = [
      {"x-ratelimit-limit", "10"},
      {"X-RateLimit-Remaining", "3"},
      {"x-ratelimit-reset", "2"},
      {"x-daily-requests-left", "900"},
      {"retry-after", "5"}
    ]

    assert %{
             limit: 10,
             remaining: 3,
             reset: 2,
             daily_requests_left: 900,
             retry_after: 5
           } = RateLimit.from_headers(headers)
  end

  test "returns nil when no rate-limit headers present" do
    assert RateLimit.from_headers([{"content-type", "application/json"}]) == nil
  end

  test "delay_ms prefers retry-after then reset" do
    assert RateLimit.delay_ms(%{retry_after: 5, reset: 2}) == 5_000
    assert RateLimit.delay_ms(%{reset: 2}) == 2_000
    assert RateLimit.delay_ms(%{}) == nil
  end
end
