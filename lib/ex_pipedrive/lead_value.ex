defmodule ExPipedrive.LeadValue do
  @moduledoc """
  Represents a lead value in Pipedrive.

  Values decoded from API maps retain their currency code. A bare numeric value
  has no currency context, so its `currency` is `nil`.
  """
  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :amount, float()
    field :currency, String.t() | nil
  end

  def new(nil), do: nil

  def new(value) when is_number(value) do
    %__MODULE__{amount: normalize_amount(value), currency: nil}
  end

  def new(map) do
    map
    |> atomize_keys()
    |> Map.update(:amount, nil, &normalize_amount/1)
    |> then(&struct(__MODULE__, &1))
  end

  defp normalize_amount(amount) when is_integer(amount), do: amount * 1.0
  defp normalize_amount(amount), do: amount
end
