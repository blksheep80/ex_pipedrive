defmodule ExPipedrive.Cursor do
  @moduledoc """
  Cursor pagination helpers for Pipedrive API v2.

  Pipedrive allows up to #{500} items per page via `limit`. Use `stream/2` to
  lazily follow `next_cursor` until it is `nil`.
  """

  alias ExPipedrive.Error
  alias ExPipedrive.Page

  @max_limit 500
  @default_limit 100

  @doc """
  Maximum page size accepted by Pipedrive API v2.
  """
  @spec max_limit() :: pos_integer()
  def max_limit, do: @max_limit

  @doc """
  Clamps a requested limit into `1..#{500}` (default #{100}).
  """
  @spec clamp_limit(nil | integer()) :: pos_integer()
  def clamp_limit(nil), do: @default_limit

  def clamp_limit(limit) when is_integer(limit) and limit > 0 do
    min(limit, @max_limit)
  end

  def clamp_limit(_), do: @default_limit

  @doc """
  Lazily streams entities by repeatedly calling `fetch_page`.

  `fetch_page` receives `[cursor: cursor_or_nil, limit: limit]` and must return
  `{:ok, %ExPipedrive.Page{}}` or `{:error, %ExPipedrive.Error{}}`.

  On error, the stream raises (`ExPipedrive.Error` is an exception). Empty pages
  with a `nil` cursor terminate the stream cleanly.
  """
  @spec stream((keyword() -> {:ok, Page.t()} | {:error, Error.t()}), keyword()) :: Enumerable.t()
  def stream(fetch_page, opts \\ []) when is_function(fetch_page, 1) do
    limit = clamp_limit(Keyword.get(opts, :limit))
    start_cursor = Keyword.get(opts, :cursor)

    Stream.resource(
      fn -> {:cont, start_cursor} end,
      fn
        {:halt, _} ->
          {:halt, :done}

        {:cont, cursor} ->
          case fetch_page.(cursor: cursor, limit: limit) do
            {:ok, %Page{data: data, next_cursor: nil}} ->
              {data, {:halt, :done}}

            {:ok, %Page{data: data, next_cursor: next}} ->
              {data, {:cont, next}}

            {:error, %Error{} = error} ->
              raise error

            {:error, other} ->
              raise Error.from_transport(other)
          end
      end,
      fn _acc -> :ok end
    )
  end
end
