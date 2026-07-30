defmodule ExPipedrive.Middleware.Retry do
  @moduledoc """
  Retries retriable Pipedrive HTTP failures with backoff.

  Retries:

  - HTTP **429** (rate limited)
  - HTTP **502 / 503 / 504**
  - Tesla transport errors (`{:error, reason}`)

  For 429 responses, prefers `Retry-After` (then `x-ratelimit-reset`) from
  `ExPipedrive.RateLimit`. Otherwise uses exponential backoff with jitter
  (same shape as `Tesla.Middleware.Retry`).

  ## Options

  - `:delay` — base delay in ms (default `100`)
  - `:max_retries` — retries after the first attempt (default `3`)
  - `:max_delay` — cap for computed delay in ms (default `5_000`)
  - `:jitter_factor` — `0.0..1.0` (default `0.2`)
  - `:sleep` — `fn ms -> :ok end` (default `:timer.sleep/1`; override in tests)
  """

  @behaviour Tesla.Middleware

  alias ExPipedrive.RateLimit

  @retriable_statuses [429, 502, 503, 504]

  @defaults [
    delay: 100,
    max_retries: 3,
    max_delay: 5_000,
    jitter_factor: 0.2
  ]

  @impl Tesla.Middleware
  def call(env, next, opts) do
    opts = opts || []

    context = %{
      retries: 0,
      delay: integer_opt!(opts, :delay, 1),
      max_retries: integer_opt!(opts, :max_retries, 0),
      max_delay: integer_opt!(opts, :max_delay, 1),
      jitter_factor: float_opt!(opts, :jitter_factor, 0, 1),
      sleep: Keyword.get(opts, :sleep, &:timer.sleep/1)
    }

    retry(env, next, context)
  end

  defp retry(env, next, %{max_retries: 0}), do: Tesla.run(env, next)

  defp retry(env, next, %{max_retries: max, retries: max} = context) do
    env
    |> put_retry_count(context)
    |> Tesla.run(next)
  end

  defp retry(env, next, context) do
    result =
      env
      |> put_retry_count(context)
      |> Tesla.run(next)

    if retriable?(result) do
      sleep_for(result, context)
      retry(env, next, update_in(context, [:retries], &(&1 + 1)))
    else
      result
    end
  end

  defp retriable?({:ok, %Tesla.Env{status: status}}) when status in @retriable_statuses, do: true
  defp retriable?({:error, _}), do: true
  defp retriable?(_), do: false

  defp sleep_for({:ok, %Tesla.Env{headers: headers}}, context) do
    delay =
      case RateLimit.delay_ms(headers) do
        nil -> backoff_ms(context)
        ms -> min(ms, context.max_delay)
      end

    context.sleep.(delay)
  end

  defp sleep_for({:error, _}, context), do: context.sleep.(backoff_ms(context))

  defp backoff_ms(%{max_delay: cap, delay: base, retries: attempt, jitter_factor: jitter_factor}) do
    factor = Bitwise.bsl(1, attempt)
    max_sleep = min(cap, base * factor)
    jitter = 1 - jitter_factor * :rand.uniform()
    trunc(max_sleep * jitter)
  end

  defp put_retry_count(env, %{retries: 0}), do: env

  defp put_retry_count(env, %{retries: retries}) do
    %{env | opts: Keyword.put(env.opts, :retry_count, retries)}
  end

  defp integer_opt!(opts, key, min) do
    case Keyword.fetch(opts, key) do
      {:ok, value} when is_integer(value) and value >= min -> value
      {:ok, invalid} -> raise ArgumentError, "expected :#{key} >= #{min}, got #{inspect(invalid)}"
      :error -> @defaults[key]
    end
  end

  defp float_opt!(opts, key, min, max) do
    case Keyword.fetch(opts, key) do
      {:ok, value} when is_float(value) and value >= min and value <= max ->
        value

      {:ok, invalid} ->
        raise ArgumentError,
              "expected :#{key} float in #{min}..#{max}, got #{inspect(invalid)}"

      :error ->
        @defaults[key]
    end
  end
end
