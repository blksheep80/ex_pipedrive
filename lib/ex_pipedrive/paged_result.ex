defmodule LineDrive.PagedResult do
  @moduledoc """
  This module and enclosed structs represent paged response data from pipedrive.
  """

  use TypedStruct

  alias LineDrive.AdditionalData

  typedstruct do
    field :success, boolean()
    field :data, list(any())
    field :additional_data, AdditionalData.t()
    field :related_objects, map()
  end

  def new(
        data,
        %{
          "success" => success,
          "additional_data" => additional_data
        } = metadata
      ) do
    %__MODULE__{
      success: success,
      data: data,
      additional_data: AdditionalData.new(additional_data),
      related_objects: Map.get(metadata, :related_objects, [])
    }
  end
end
