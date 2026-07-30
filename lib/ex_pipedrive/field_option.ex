defmodule LineDrive.FieldOption do
  @moduledoc """
  This is a custom field option for person, org, and other custom fields in pipedrive's API
  """
  use TypedStruct
  use LineDrive.Structable

  typedstruct do
    field :id, non_neg_integer()
    field :label, String.t()
  end
end
