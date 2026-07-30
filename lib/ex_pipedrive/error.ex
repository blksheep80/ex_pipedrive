defmodule ExPipedrive.Error do
  @moduledoc """
  Normalized error returned by ExPipedrive public APIs as `{:error, %ExPipedrive.Error{}}`.

  Distinguishes API failures from transport failures and classifies common HTTP
  outcomes so callers can pattern-match on `:kind`:

      case ExPipedrive.get_deal(client, id) do
        {:ok, deal} -> deal
        {:error, %ExPipedrive.Error{kind: :not_found}} -> :missing
        {:error, %ExPipedrive.Error{kind: :rate_limited} = err} -> backoff(err)
        {:error, %ExPipedrive.Error{kind: :unauthorized}} -> reauth()
        {:error, %ExPipedrive.Error{kind: :transport} = err} -> retry?(err)
      end

  Debugging context (`status`, `body`, `headers`, `request_id`, `rate_limit`,
  original `reason`) is preserved when available. See `ExPipedrive.RateLimit`
  for the `rate_limit` map shape.
  """

  alias ExPipedrive.RateLimit

  defexception [
    :kind,
    :message,
    :status,
    :body,
    :headers,
    :request_id,
    :rate_limit,
    :reason
  ]

  @type kind ::
          :validation
          | :unauthorized
          | :forbidden
          | :not_found
          | :rate_limited
          | :api
          | :transport
          | :unknown

  @type t :: %__MODULE__{
          kind: kind(),
          message: String.t() | nil,
          status: pos_integer() | nil,
          body: term(),
          headers: [{binary(), binary()}],
          request_id: String.t() | nil,
          rate_limit: RateLimit.t() | nil,
          reason: term()
        }

  @impl true
  def message(%__MODULE__{message: message, kind: kind, status: status})
      when is_binary(message) and message != "" do
    status_part = if status, do: " (HTTP #{status})", else: ""
    "#{kind}#{status_part}: #{message}"
  end

  def message(%__MODULE__{kind: kind, status: status, reason: reason}) do
    status_part = if status, do: " (HTTP #{status})", else: ""
    reason_part = if reason, do: " — #{inspect(reason)}", else: ""
    "#{kind}#{status_part}#{reason_part}"
  end

  @doc """
  Builds an error from a completed Tesla response (HTTP layer succeeded).
  """
  @spec from_env(Tesla.Env.t()) :: t()
  def from_env(%Tesla.Env{} = env) do
    headers = normalize_headers(env.headers)
    body = env.body
    status = env.status

    %__MODULE__{
      kind: classify_kind(status, body),
      message: extract_message(body),
      status: status,
      body: body,
      headers: headers,
      request_id: request_id(headers),
      rate_limit: RateLimit.from_headers(headers),
      reason: nil
    }
  end

  @doc """
  Builds an error from a Tesla adapter / transport failure.
  """
  @spec from_transport(term()) :: t()
  def from_transport(reason) do
    %__MODULE__{
      kind: :transport,
      message: "transport error",
      status: nil,
      body: nil,
      headers: [],
      request_id: nil,
      rate_limit: nil,
      reason: reason
    }
  end

  @doc """
  True when the error is a rate-limit response.
  """
  @spec rate_limited?(t() | term()) :: boolean()
  def rate_limited?(%__MODULE__{kind: :rate_limited}), do: true
  def rate_limited?(_), do: false

  @doc """
  True when the error is an auth failure (401 / unauthorized).
  """
  @spec unauthorized?(t() | term()) :: boolean()
  def unauthorized?(%__MODULE__{kind: :unauthorized}), do: true
  def unauthorized?(_), do: false

  @doc """
  True when the failure was at the HTTP transport layer (no usable response).
  """
  @spec transport?(t() | term()) :: boolean()
  def transport?(%__MODULE__{kind: :transport}), do: true
  def transport?(_), do: false

  @doc """
  True when the failure came from the Pipedrive API response (not transport).
  """
  @spec api?(t() | term()) :: boolean()
  def api?(%__MODULE__{kind: kind})
      when kind in [:validation, :unauthorized, :forbidden, :not_found, :rate_limited, :api],
      do: true

  def api?(_), do: false

  defp classify_kind(401, _body), do: :unauthorized
  defp classify_kind(403, _body), do: :forbidden
  defp classify_kind(404, _body), do: :not_found
  defp classify_kind(429, _body), do: :rate_limited

  defp classify_kind(status, _body) when is_integer(status) and status in 400..499,
    do: :validation

  defp classify_kind(status, _body) when is_integer(status) and status >= 500, do: :api

  defp classify_kind(_status, body) do
    if api_failure_body?(body), do: :api, else: :unknown
  end

  defp api_failure_body?(%{"success" => false}), do: true
  defp api_failure_body?(%{success: false}), do: true
  defp api_failure_body?(_), do: false

  defp extract_message(%{"error" => message}) when is_binary(message), do: message
  defp extract_message(%{"message" => message}) when is_binary(message), do: message
  defp extract_message(%{error: message}) when is_binary(message), do: message
  defp extract_message(%{message: message}) when is_binary(message), do: message
  defp extract_message(%{"error_info" => message}) when is_binary(message), do: message
  defp extract_message(_), do: nil

  defp normalize_headers(headers) when is_list(headers), do: headers
  defp normalize_headers(_), do: []

  defp request_id(headers) do
    Enum.find_value(headers, fn
      {key, value} when is_binary(key) and is_binary(value) ->
        if String.downcase(key) in ["x-request-id", "x-correlation-id"], do: value

      _ ->
        nil
    end)
  end
end
