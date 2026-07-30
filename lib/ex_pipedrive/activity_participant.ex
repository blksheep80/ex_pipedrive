defmodule LineDrive.ActivityParticipant do
  @moduledoc """
  This module and enclosed struct represent a activity participant in pipedrive.
  """

  use TypedStruct
  use LineDrive.Structable

  typedstruct enforce: true do
    field :person_id, pos_integer()
    field :primary_flag, boolean()
  end
end
