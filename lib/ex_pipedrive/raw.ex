defmodule ExPipedrive.Raw do
  @moduledoc """
  Escape hatch for Pipedrive endpoints without a first-class module.

  Requests still go through the authenticated Tesla client (auth, JSON) and
  `ExPipedrive.Response` / `ExPipedrive.Error` normalization. Prefer resource
  modules when they exist; use this for unsupported or experimental paths.

  ## Path forms

  - Resource segment (versioned via `:api_version`, default `:v2`): `"dealFields"`
  - Absolute API path: `"/api/v1/dealFields"` or `"/api/v2/itemSearch"`

  ## Example

      {:ok, body} =
        ExPipedrive.Raw.request(client, :get, "dealFields",
          api_version: :v1,
          query: [limit: 100]
        )

      {:ok, body} =
        ExPipedrive.Raw.request(client, :post, "/api/v2/deals",
          body: %{title: "From raw", value: 100, currency: "USD"}
        )
  """

  alias ExPipedrive.Error
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  @type method :: :get | :post | :put | :patch | :delete
  @type path :: String.t() | atom()

  @methods [:get, :post, :put, :patch, :delete]
  @default_success_statuses [200, 201, 204]

  @doc """
  Performs a raw HTTP request against Pipedrive.

  ## Options

  - `:query` — query string keyword list or map
  - `:body` — JSON-encodable body (POST / PUT / PATCH)
  - `:headers` — extra request headers as `[{binary, binary}]`
  - `:api_version` — `:v1` or `:v2` when `path` is a resource segment
    (ignored when `path` is already an absolute `/api/v…` path)
  - `:success_statuses` — HTTP statuses treated as success (default
    `[200, 201, 204]`)
  - `:opts` — Tesla request opts (e.g. `path_params: [id: 1]`)

  Returns `{:ok, body}` with the decoded response body, or
  `{:error, %ExPipedrive.Error{}}`.
  """
  @spec request(Client.t(), method(), path(), keyword()) ::
          {:ok, term()} | {:error, Error.t()}
  def request(%Client{} = client, method, path, opts \\ [])
      when method in @methods and (is_binary(path) or is_atom(path)) and is_list(opts) do
    {api_version, opts} = Keyword.pop(opts, :api_version)
    {success_statuses, opts} = Keyword.pop(opts, :success_statuses, @default_success_statuses)
    {body, opts} = Keyword.pop(opts, :body)
    {query, opts} = Keyword.pop(opts, :query, [])
    {headers, opts} = Keyword.pop(opts, :headers, [])
    {tesla_opts, remaining} = Keyword.pop(opts, :opts, [])

    if remaining != [] do
      raise ArgumentError,
            "unknown Raw.request options: #{inspect(Keyword.keys(remaining))}; " <>
              "expected :query, :body, :headers, :api_version, :success_statuses, :opts"
    end

    url = resolve_path(path, api_version)

    request_opts = [
      query: query,
      headers: normalize_headers(headers),
      opts: tesla_opts
    ]

    client
    |> do_request(method, url, body, request_opts)
    |> Response.map(List.wrap(success_statuses), fn %Tesla.Env{body: response_body} ->
      response_body
    end)
  end

  defp resolve_path(path, api_version) do
    path_string = path |> to_string() |> String.trim()

    cond do
      absolute_api_path?(path_string) ->
        path_string

      is_nil(api_version) ->
        Request.path(path_string)

      true ->
        Request.path(path_string, api_version: api_version)
    end
  end

  defp absolute_api_path?("/api/v1" <> _), do: true
  defp absolute_api_path?("/api/v2" <> _), do: true
  defp absolute_api_path?(_), do: false

  defp normalize_headers(headers) when is_list(headers), do: headers
  defp normalize_headers(_), do: []

  defp do_request(client, :get, url, _body, opts), do: Tesla.get(client, url, opts)

  defp do_request(client, :post, url, body, opts), do: Tesla.post(client, url, body, opts)

  defp do_request(client, :put, url, body, opts), do: Tesla.put(client, url, body, opts)

  defp do_request(client, :patch, url, body, opts), do: Tesla.patch(client, url, body, opts)

  defp do_request(client, :delete, url, _body, opts), do: Tesla.delete(client, url, opts)
end
