defmodule ExPipedrive.Webhook.Handler do
  @moduledoc """
  Behaviour for consuming normalized Pipedrive webhook events.

  Configure a module implementing this behaviour when mounting
  `ExPipedrive.Incoming.Handler`. The callback runs synchronously, so handlers
  should acknowledge quickly and delegate longer work to the host application.

  This is the intended public handler boundary for the future
  `ex_pipedrive_web` package. The Plug itself stays optional.
  """

  alias ExPipedrive.Webhook.Event

  @callback handle_event(Event.t()) :: term()
end
