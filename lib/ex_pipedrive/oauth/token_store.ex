defmodule ExPipedrive.Oauth.TokenStore do
  @moduledoc """
  Behaviour for persisting OAuth token bundles.

  Core does **not** depend on Ecto. Host apps implement this behaviour
  (database, ETS, encrypted secrets, …). An in-memory store is provided for
  tests and single-process scripts — see `ExPipedrive.Oauth.TokenStore.Memory`.
  """

  alias ExPipedrive.Oauth.Token

  @type id :: term()

  @callback get(id()) :: {:ok, Token.t()} | {:error, :not_found}
  @callback put(id(), Token.t()) :: :ok | {:error, term()}
end
