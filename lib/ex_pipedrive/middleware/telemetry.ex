defmodule ExPipedrive.Middleware.Telemetry do
  @moduledoc """
  Emits `:telemetry` events for ExPipedrive HTTP requests.

  Logging is **not** enabled — attach handlers in the host app as needed.

  ## Events

  * `[:ex_pipedrive, :request, :start]`
    * Measurement: `%{system_time: integer()}`
    * Metadata: `%{env: Tesla.Env.t()}`

  * `[:ex_pipedrive, :request, :stop]`
    * Measurement: `%{duration: integer()}` (native time)
    * Metadata: `%{env: Tesla.Env.t(), rate_limit: map() | nil, retry_count: non_neg_integer()}`
      and optionally `error: term()` on transport failure

  * `[:ex_pipedrive, :request, :exception]`
    * Measurement: `%{duration: integer()}`
    * Metadata: `%{env: Tesla.Env.t(), kind: atom(), reason: term(), stacktrace: list()}`

  ## Options

  - `:metadata` — extra metadata merged into every event
  """

  @behaviour Tesla.Middleware

  alias ExPipedrive.RateLimit

  @impl Tesla.Middleware
  def call(env, next, opts) do
    opts = opts || []
    extra = Keyword.get(opts, :metadata, %{})
    start_time = System.monotonic_time()

    :telemetry.execute(
      [:ex_pipedrive, :request, :start],
      %{system_time: System.system_time()},
      Map.merge(extra, %{env: env})
    )

    try do
      case Tesla.run(env, next) do
        {:ok, env} = result ->
          stop(start_time, env, extra, nil)
          result

        {:error, reason} = result ->
          stop(start_time, env, extra, reason)
          result
      end
    catch
      kind, reason ->
        :telemetry.execute(
          [:ex_pipedrive, :request, :exception],
          %{duration: System.monotonic_time() - start_time},
          Map.merge(extra, %{
            env: env,
            kind: kind,
            reason: reason,
            stacktrace: __STACKTRACE__
          })
        )

        :erlang.raise(kind, reason, __STACKTRACE__)
    end
  end

  defp stop(start_time, %Tesla.Env{} = env, extra, error) do
    meta =
      extra
      |> Map.merge(%{
        env: env,
        rate_limit: RateLimit.from_headers(env.headers || []),
        retry_count: Keyword.get(env.opts, :retry_count, 0)
      })
      |> maybe_put_error(error)

    :telemetry.execute(
      [:ex_pipedrive, :request, :stop],
      %{duration: System.monotonic_time() - start_time},
      meta
    )
  end

  defp maybe_put_error(meta, nil), do: meta
  defp maybe_put_error(meta, error), do: Map.put(meta, :error, error)
end
