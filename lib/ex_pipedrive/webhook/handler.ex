defmodule ExPipedrive.Webhook.Handler do
  @moduledoc """
  Behaviour for consuming normalized Pipedrive webhook events.

  Configure a module implementing this behaviour when mounting
  `ExPipedriveWeb.Incoming.Handler` from the optional `ex_pipedrive_web`
  package. The callback runs synchronously, so handlers should acknowledge
  quickly and delegate longer work to the host application.

  Event structs stay in core so API-only apps can decode webhook payloads
  without Plug.
  """

  alias ExPipedrive.Webhook.Event

  @callback handle_event(Event.t()) :: term()
end
