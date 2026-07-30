defmodule ExPipedrive.Webhook.Event do
  @moduledoc """
  A normalized Pipedrive webhook event.

  `from_payload/1` accepts the v1 `current`/`previous` envelope and the
  equivalent v2-ish `data` field. Deal and person records are decoded into
  `ExPipedrive.Deal` and `ExPipedrive.Person`; other resources remain maps.

  This module is part of the in-repository `ex_pipedrive_web` surface. It is
  deliberately independent of Plug so it can move unchanged to a future
  optional `ex_pipedrive_web` package.
  """

  alias ExPipedrive.{Deal, Person}

  @actions ~w(added created deleted updated)

  @enforce_keys [:name, :action, :resource, :raw]
  defstruct [
    :name,
    :action,
    :resource,
    :current,
    :previous,
    :meta,
    :diff,
    :raw
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          action: String.t() | nil,
          resource: String.t() | nil,
          current: Deal.t() | Person.t() | map() | nil,
          previous: Deal.t() | Person.t() | map() | nil,
          meta: map(),
          diff: map(),
          raw: map()
        }

  @doc "Normalizes a Pipedrive webhook payload into an event."
  @spec from_payload(map()) :: {:ok, t()} | {:error, :invalid_payload}
  def from_payload(payload) when is_map(payload) do
    case event_name(payload) do
      name when is_binary(name) ->
        {action, resource} = event_parts(name, payload)
        current = Map.get(payload, "current") || Map.get(payload, "data")
        previous = Map.get(payload, "previous")

        {:ok,
         %__MODULE__{
           name: name,
           action: action,
           resource: resource,
           current: decode(resource, current),
           previous: decode(resource, previous),
           meta: Map.get(payload, "meta", %{}),
           diff: diff(current, previous),
           raw: payload
         }}

      _ ->
        {:error, :invalid_payload}
    end
  end

  def from_payload(_), do: {:error, :invalid_payload}

  defp event_name(payload) do
    Map.get(payload, "event") || Map.get(payload, "event_name") || Map.get(payload, "event_type")
  end

  defp event_parts(name, payload) do
    meta = Map.get(payload, "meta", %{})

    case String.split(name, ".", parts: 2) do
      [action, resource] when action in @actions -> {action, resource}
      [resource, action] when action in @actions -> {action, resource}
      _ -> {Map.get(meta, "action"), Map.get(meta, "object")}
    end
  end

  defp decode("deal", payload) when is_map(payload), do: Deal.new(payload)
  defp decode("person", payload) when is_map(payload), do: Person.new(payload)
  defp decode(_, payload), do: payload

  defp diff(current, previous) when is_map(current) and is_map(previous) do
    Map.filter(current, fn {key, value} -> Map.get(previous, key) != value end)
  end

  defp diff(_, _), do: %{}
end
