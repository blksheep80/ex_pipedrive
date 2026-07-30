defmodule ExPipedrive.Oauth.TokenStore.Memory do
  @moduledoc """
  In-memory `TokenStore` backed by a public ETS table.

  Suitable for tests and single-node scripts. Host apps should implement
  `ExPipedrive.Oauth.TokenStore` with durable storage (e.g. Ecto).
  """

  @behaviour ExPipedrive.Oauth.TokenStore

  alias ExPipedrive.Oauth.Token

  @table __MODULE__

  @doc """
  Ensures the ETS table exists. Safe to call multiple times.
  """
  def start_link(opts \\ []) do
    _ = opts
    ensure_table()
    {:ok, self()}
  end

  @impl true
  def get(id) do
    ensure_table()

    case :ets.lookup(@table, id) do
      [{^id, %Token{} = token}] -> {:ok, token}
      [] -> {:error, :not_found}
    end
  end

  @impl true
  def put(id, %Token{} = token) do
    ensure_table()
    true = :ets.insert(@table, {id, token})
    :ok
  end

  @doc false
  def clear do
    ensure_table()
    true = :ets.delete_all_objects(@table)
    :ok
  end

  defp ensure_table do
    case :ets.whereis(@table) do
      :undefined ->
        :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])

      tid ->
        tid
    end
  end
end
