defmodule ExPipedrive.LeadSource do
  @moduledoc """
  A fixed lead source name from Pipedrive's `/api/v1/leadSources` list.

  Pipedrive maintains this list; it cannot be modified through the API.
  Leads created via the API are assigned the `"API"` source.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :name, String.t()
  end
end
