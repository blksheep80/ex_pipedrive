defmodule ExPipedrive.LeadOrganization do
  @moduledoc """
  This module represent a lead organization in pipedrive.
  """
  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :name, String.t()
  end
end
