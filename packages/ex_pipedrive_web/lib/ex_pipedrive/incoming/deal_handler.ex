defmodule ExPipedrive.Incoming.DealHandler do
  @moduledoc """
  Compatibility alias for `ExPipedriveWeb.Incoming.DealHandler`.
  """

  defmacro __using__(opts) do
    quote do
      use ExPipedriveWeb.Incoming.DealHandler, unquote(opts)
    end
  end

  defdelegate deal_updated(payload), to: ExPipedriveWeb.Incoming.DealHandler
end
