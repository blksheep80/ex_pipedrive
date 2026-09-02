defmodule ExPipedrive.Incoming.PersonHandler do
  @moduledoc """
  Compatibility alias for `ExPipedriveWeb.Incoming.PersonHandler`.
  """

  defmacro __using__(opts) do
    quote do
      use ExPipedriveWeb.Incoming.PersonHandler, unquote(opts)
    end
  end

  defdelegate person_updated(payload), to: ExPipedriveWeb.Incoming.PersonHandler
end
