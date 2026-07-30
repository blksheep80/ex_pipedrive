defmodule ExPipedrive.RateLimit do
  @moduledoc """
  Parses Pipedrive rate-limit response headers.

  Recognizes:

  - `x-ratelimit-limit` / `x-ratelimit-remaining` / `x-ratelimit-reset`
  - `x-daily-requests-left`
  - `retry-after` (seconds or HTTP-date)
  """

  @type t :: %{
          optional(:limit) => non_neg_integer(),
          optional(:remaining) => non_neg_integer(),
          optional(:reset) => non_neg_integer(),
          optional(:daily_requests_left) => non_neg_integer(),
          optional(:retry_after) => non_neg_integer()
        }

  @doc """
  Builds a rate-limit map from a Tesla/HTTP header list.

  Returns `nil` when no recognized rate-limit headers are present.
  """
  @spec from_headers([{binary(), binary()}]) :: t() | nil
  def from_headers(headers) when is_list(headers) do
    normalized = normalize(headers)

    info =
      %{}
      |> maybe_put(:limit, parse_int(normalized["x-ratelimit-limit"]))
      |> maybe_put(:remaining, parse_int(normalized["x-ratelimit-remaining"]))
      |> maybe_put(:reset, parse_int(normalized["x-ratelimit-reset"]))
      |> maybe_put(:daily_requests_left, parse_int(normalized["x-daily-requests-left"]))
      |> maybe_put(:retry_after, parse_retry_after(normalized["retry-after"]))

    if map_size(info) == 0, do: nil, else: info
  end

  def from_headers(_), do: nil

  @doc """
  Delay in milliseconds before retrying, preferring `Retry-After`, then
  `x-ratelimit-reset`, otherwise `nil`.
  """
  @spec delay_ms(t() | nil | [{binary(), binary()}]) :: non_neg_integer() | nil
  def delay_ms(nil), do: nil

  def delay_ms(info) when is_map(info) do
    cond do
      is_integer(info[:retry_after]) -> info[:retry_after] * 1000
      is_integer(info[:reset]) -> info[:reset] * 1000
      true -> nil
    end
  end

  def delay_ms(headers) when is_list(headers), do: delay_ms(from_headers(headers))

  defp normalize(headers) do
    Map.new(headers, fn
      {k, v} when is_binary(k) and is_binary(v) ->
        {String.downcase(k), String.trim(v)}

      {k, v} when is_atom(k) and is_binary(v) ->
        {k |> Atom.to_string() |> String.downcase(), String.trim(v)}

      _ ->
        {"", ""}
    end)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp parse_int(nil), do: nil

  defp parse_int(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} when int >= 0 -> int
      _ -> nil
    end
  end

  defp parse_retry_after(nil), do: nil

  defp parse_retry_after(value) when is_binary(value) do
    case Integer.parse(value) do
      {seconds, ""} when seconds >= 0 ->
        seconds

      _ ->
        case parse_http_date(value) do
          {:ok, datetime} ->
            max(DateTime.diff(datetime, DateTime.utc_now(), :second), 0)

          :error ->
            nil
        end
    end
  end

  defp parse_http_date(value) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _} ->
        {:ok, datetime}

      _ ->
        # Tesla/Pipedrive usually send integer seconds; HTTP-date is rare.
        :error
    end
  end
end
