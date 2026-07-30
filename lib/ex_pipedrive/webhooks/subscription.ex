defmodule ExPipedrive.Webhooks.Subscription do
  @moduledoc """
  A Pipedrive webhook subscription returned by the API v1 Webhooks endpoints.

  This represents an outgoing Pipedrive subscription. It is separate from
  `ExPipedrive.Webhook.Event`, which normalizes incoming webhook deliveries.
  """

  @enforce_keys [:id, :subscription_url, :event_action, :event_object]
  defstruct [
    :id,
    :subscription_url,
    :event_action,
    :event_object,
    :name,
    :user_id,
    :company_id,
    :version,
    :http_auth_user,
    :is_active,
    :add_time,
    :remove_time,
    :original_object
  ]

  @type t :: %__MODULE__{
          id: pos_integer(),
          subscription_url: String.t(),
          event_action: String.t(),
          event_object: String.t(),
          name: String.t() | nil,
          user_id: pos_integer() | nil,
          company_id: pos_integer() | nil,
          version: String.t() | nil,
          http_auth_user: String.t() | nil,
          is_active: boolean() | nil,
          add_time: String.t() | nil,
          remove_time: String.t() | nil,
          original_object: map() | nil
        }

  @doc false
  @spec new(map()) :: t()
  def new(map) when is_map(map) do
    %__MODULE__{
      id: get(map, :id),
      subscription_url: get(map, :subscription_url),
      event_action: get(map, :event_action),
      event_object: get(map, :event_object),
      name: get(map, :name),
      user_id: get(map, :user_id),
      company_id: get(map, :company_id),
      version: get(map, :version),
      http_auth_user: get(map, :http_auth_user),
      is_active: get(map, :is_active),
      add_time: get(map, :add_time),
      remove_time: get(map, :remove_time),
      original_object: map
    }
  end

  defp get(map, key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))
end
