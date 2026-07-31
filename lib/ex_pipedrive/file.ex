defmodule ExPipedrive.File do
  @moduledoc """
  Metadata for a Pipedrive file (attachment).

  The binary contents are not embedded here — use `ExPipedrive.Files.download/2`
  or the `url` field when present.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :name, String.t()
    field :file_name, String.t()
    field :file_size, non_neg_integer()
    field :file_type, String.t()
    field :active_flag, boolean()
    field :inline_flag, boolean()
    field :remote_location, String.t()
    field :remote_id, String.t()
    field :s3_bucket, String.t()
    field :url, String.t()
    field :description, String.t()
    field :deal_id, pos_integer()
    field :person_id, pos_integer()
    field :org_id, pos_integer()
    field :product_id, pos_integer()
    field :activity_id, pos_integer()
    field :lead_id, String.t()
    field :project_id, pos_integer()
    field :add_time, DateTime.t()
    field :update_time, DateTime.t()
    field :user_id, pos_integer()
    field :original_object, map()
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.update(:update_time, nil, &parse_datetime/1)
    |> Map.put(:original_object, original)
  end
end
