defmodule ExPipedrive.PagedResult do
  @moduledoc """
  Offset-paginated response wrapper for Pipedrive API v1 list endpoints.

  Prefer `{:ok, %PagedResult{}}` (or v2 `%ExPipedrive.Page{}`) over bare lists
  when the API returns pagination metadata. See `ExPipedrive.Page` for the
  documented list-return conventions.
  """

  use TypedStruct

  alias ExPipedrive.AdditionalData

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
