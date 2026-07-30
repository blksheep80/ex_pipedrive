defmodule LineDrive.User do
  @moduledoc """
  This module represents a user in pipedrive.
  """

  use TypedStruct
  use LineDrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :name, String.t()
    field :email, String.t(), enforce: true
    field :active_flag, boolean(), default: true
  end

  def new(nil) do
    struct(__MODULE__)
  end

  def new(int) when is_integer(int) do
    struct(__MODULE__, %{id: int})
  end

  def new(map) do
    map
    |> atomize_keys()
    |> then(&struct(__MODULE__, &1))
  end
end
