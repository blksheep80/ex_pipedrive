defmodule LineDrive.LeadValue do
  @moduledoc """
  This module represent a lead value in pipedrive.
  """
  use TypedStruct
  use LineDrive.Structable

  typedstruct do
    field :amount, float()
    field :currency, String.t()
  end

  def new(nil), do: nil

  def new(val) when is_integer(val) do
    %__MODULE__{amount: val, currency: "USD"}
  end

  def new(map) do
    map
    |> atomize_keys()
    |> then(&struct(__MODULE__, &1))
  end
end
