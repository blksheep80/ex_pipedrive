defmodule LineDrive.AdditionalData do
  @moduledoc """
  This module and enclosed structs represent additional metadata in response data from pipedrive.
  """

  use TypedStruct

  alias LineDrive.Pagination

  typedstruct do
    field :pagination, Pagination.t()
    field :next_cursor, String.t()
    field :limit, pos_integer()
  end

  def new(%{"next_cursor" => _} = additional_data) do
    %__MODULE__{
      next_cursor: additional_data["next_cursor"],
      limit: additional_data["limit"]
    }
  end

  def new(%{"pagination" => pagination}) do
    %__MODULE__{pagination: Pagination.new(pagination)}
  end
end
