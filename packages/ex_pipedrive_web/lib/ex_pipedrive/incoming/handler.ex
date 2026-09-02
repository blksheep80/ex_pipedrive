defmodule ExPipedrive.Incoming.Handler do
  @moduledoc """
  Compatibility alias for `ExPipedriveWeb.Incoming.Handler`.

  Prefer `ExPipedriveWeb.Incoming.Handler` in new code. This module exists so
  existing `forward "/webhooks", to: ExPipedrive.Incoming.Handler` mounts keep
  working after adding `:ex_pipedrive_web`.
  """

  defdelegate init(opts), to: ExPipedriveWeb.Incoming.Handler
  defdelegate call(conn, opts), to: ExPipedriveWeb.Incoming.Handler
  defdelegate process_event(payload), to: ExPipedriveWeb.Incoming.Handler
  defdelegate normalize_event(payload), to: ExPipedriveWeb.Incoming.Handler
  defdelegate transform_event(event_type, payload), to: ExPipedriveWeb.Incoming.Handler
  defdelegate deliver_event(event, opts), to: ExPipedriveWeb.Incoming.Handler
end
