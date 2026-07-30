defmodule ExPipedrive.Request do
  @moduledoc """
  Versioned Pipedrive API request helpers.

  Owns path construction so resource modules do not hard-code `/api/v1` or
  `/api/v2`. Defaults to **v2**; pass `api_version: :v1` for controlled fallback
  without duplicating HTTP logic.
  """

  @default_api_version :v2
  @version_opts [:api_version]

  @type api_version :: :v1 | :v2
  @type resource :: String.t() | atom()
  @type result :: {:ok, Tesla.Env.t()} | {:error, any()}

  @doc """
  Builds a versioned API path for a resource segment.

  ## Examples

      iex> ExPipedrive.Request.path("deals")
      "/api/v2/deals"

      iex> ExPipedrive.Request.path("deals/:id", api_version: :v1)
      "/api/v1/deals/:id"

      iex> ExPipedrive.Request.path("dealFields", api_version: :v1)
      "/api/v1/dealFields"
  """
  @spec path(resource(), keyword()) :: String.t()
  def path(resource, opts \\ []) do
    version = Keyword.get(opts, :api_version, @default_api_version)
    segment = resource |> to_string() |> String.trim_leading("/")
    "/#{version_prefix(version)}/#{segment}"
  end

  @doc """
  Performs a GET against a versioned resource path.

  Options:
  - `:api_version` — `:v2` (default) or `:v1`
  - remaining options are passed through to `Tesla.get/3` (`:query`, `:opts`, …)
  """
  @spec get(Tesla.Client.t(), resource(), keyword()) :: result()
  def get(client, resource, opts \\ []) do
    {version_opts, request_opts} = Keyword.split(opts, @version_opts)
    Tesla.get(client, path(resource, version_opts), request_opts)
  end

  @doc """
  Performs a POST against a versioned resource path.
  """
  @spec post(Tesla.Client.t(), resource(), term(), keyword()) :: result()
  def post(client, resource, body, opts \\ []) do
    {version_opts, request_opts} = Keyword.split(opts, @version_opts)
    Tesla.post(client, path(resource, version_opts), body, request_opts)
  end

  @doc """
  Performs a PUT against a versioned resource path.
  """
  @spec put(Tesla.Client.t(), resource(), term(), keyword()) :: result()
  def put(client, resource, body, opts \\ []) do
    {version_opts, request_opts} = Keyword.split(opts, @version_opts)
    Tesla.put(client, path(resource, version_opts), body, request_opts)
  end

  @doc """
  Performs a PATCH against a versioned resource path.
  """
  @spec patch(Tesla.Client.t(), resource(), term(), keyword()) :: result()
  def patch(client, resource, body, opts \\ []) do
    {version_opts, request_opts} = Keyword.split(opts, @version_opts)
    Tesla.patch(client, path(resource, version_opts), body, request_opts)
  end

  @doc """
  Performs a DELETE against a versioned resource path.
  """
  @spec delete(Tesla.Client.t(), resource(), keyword()) :: result()
  def delete(client, resource, opts \\ []) do
    {version_opts, request_opts} = Keyword.split(opts, @version_opts)
    Tesla.delete(client, path(resource, version_opts), request_opts)
  end

  defp version_prefix(:v1), do: "api/v1"
  defp version_prefix(:v2), do: "api/v2"

  defp version_prefix(other) do
    raise ArgumentError,
          "unsupported api_version #{inspect(other)}; expected :v1 or :v2"
  end
end
