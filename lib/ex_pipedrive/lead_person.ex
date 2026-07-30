defmodule ExPipedrive.LeadPerson do
  @moduledoc """
  This module represent a lead person in pipedrive.
  """
  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :name, String.t()
  end

  def new(nil), do: nil

  def new(map) do
    map
    |> atomize_keys()
    |> then(&struct(__MODULE__, &1))
  end
end
