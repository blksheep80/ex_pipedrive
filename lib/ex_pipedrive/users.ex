defmodule ExPipedrive.Users do
  @moduledoc """
  This module encapsulates calls to the pipedrive user resource API.
  """

  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.User
  alias Tesla.Client

  def find_users_by_name(%Client{} = client, term, opts \\ []) do
    search_by_email? = Keyword.get(opts, :search_by_email?, false)

    client
    |> Request.get("users/find",
      api_version: :v1,
      query: [term: term, search_by_email: search_int(search_by_email?)]
    )
    |> Response.map([200], fn %{body: %{success: true, data: data}} ->
      Enum.map(data, &User.new/1)
    end)
  end

  defp search_int(true), do: 1
  defp search_int(false), do: 0
end
