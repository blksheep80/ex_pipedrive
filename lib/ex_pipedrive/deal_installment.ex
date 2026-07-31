defmodule ExPipedrive.DealInstallment do
  @moduledoc """
  A scheduled payment entry on a deal (`/api/v2/deals/installments`).

  Listed via `GET /api/v2/deals/installments?deal_ids=...`; created and updated
  under `/api/v2/deals/:id/installments`.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :deal_id, pos_integer()
    field :description, String.t()
    field :amount, number()
    field :billing_date, Date.t()
    field :original_object, map()
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:deal_id, nil, &normalize_id/1)
    |> Map.update(:billing_date, nil, &parse_date/1)
    |> Map.put(:original_object, original)
  end
end
