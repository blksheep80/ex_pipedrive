defmodule ExPipedrive.Oauth.Token do
  @moduledoc """
  OAuth token bundle from Pipedrive's token endpoint.

  Preserves `api_domain`, expiry, and scope so host apps can refresh and
  rebuild clients without losing tenant metadata.
  """

  @enforce_keys [:access_token, :refresh_token]
  defstruct [
    :access_token,
    :refresh_token,
    :api_domain,
    :expires_at,
    :expires_in,
    :scope,
    :token_type
  ]

  @type t :: %__MODULE__{
          access_token: String.t(),
          refresh_token: String.t(),
          api_domain: String.t() | nil,
          expires_at: DateTime.t() | nil,
          expires_in: non_neg_integer() | nil,
          scope: String.t() | nil,
          token_type: String.t() | nil
        }

  @doc """
  Builds a token from a Pipedrive OAuth token JSON body.

  Computes `expires_at` from `expires_in` when present. Pass
  `default_api_domain:` when the response omits `api_domain` (e.g. some
  refresh responses) so the tenant domain is preserved.
  """
  @spec from_response(map(), keyword()) :: t()
  def from_response(map, opts \\ []) when is_map(map) and is_list(opts) do
    data = stringify_keys(map)
    expires_in = parse_expires_in(Map.get(data, "expires_in"))

    %__MODULE__{
      access_token: Map.fetch!(data, "access_token"),
      refresh_token: Map.fetch!(data, "refresh_token"),
      api_domain: Map.get(data, "api_domain") || Keyword.get(opts, :default_api_domain),
      expires_in: expires_in,
      expires_at: expires_at_from(expires_in),
      scope: Map.get(data, "scope"),
      token_type: Map.get(data, "token_type", "Bearer")
    }
  end

  @doc """
  Returns true when the access token is expired or within `skew_seconds` of expiry.

  Tokens without `expires_at` are treated as not expired (caller must refresh on 401).
  """
  @spec expired?(t(), non_neg_integer()) :: boolean()
  def expired?(%__MODULE__{expires_at: nil}, _skew_seconds), do: false

  def expired?(%__MODULE__{expires_at: %DateTime{} = expires_at}, skew_seconds)
      when is_integer(skew_seconds) and skew_seconds >= 0 do
    DateTime.compare(DateTime.add(DateTime.utc_now(), skew_seconds, :second), expires_at) != :lt
  end

  defp expires_at_from(nil), do: nil

  defp expires_at_from(expires_in) when is_integer(expires_in) do
    DateTime.add(DateTime.utc_now(), expires_in, :second)
  end

  defp parse_expires_in(nil), do: nil
  defp parse_expires_in(value) when is_integer(value), do: value

  defp parse_expires_in(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> nil
    end
  end

  defp stringify_keys(map) do
    Map.new(map, fn
      {key, value} when is_atom(key) -> {Atom.to_string(key), value}
      {key, value} when is_binary(key) -> {key, value}
    end)
  end
end
