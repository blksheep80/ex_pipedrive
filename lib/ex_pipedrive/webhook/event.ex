defmodule ExPipedrive.Webhook.Event do
  @moduledoc """
  A normalized Pipedrive webhook event.

  `from_payload/1` accepts:

  * **Webhooks v1** — top-level `"event"` (`"updated.deal"`, `"added.organization"`,
    …) with `"current"` / `"previous"` bodies
  * **Webhooks v2** — `"meta.action"` + `"meta.entity"` with `"data"` / `"previous"`
    (no top-level event name; one is synthesized as `"action.entity"`)
  * **v2-ish aliases** — `"event_type"` / `"event_name"`, and `"resource.action"`
    order (`"person.updated"`)

  ## Event type matrix

  ### Actions

  | API | Actions |
  |---|---|
  | v1 | `added`, `updated`, `deleted`, `merged` |
  | v2 | `create`, `change`, `delete` |
  | alias | `created` (treated like a first-class action token) |

  ### Typed resources (decoded when a matching entity module exists)

  | Resource key | Struct |
  |---|---|
  | `deal` | `ExPipedrive.Deal` |
  | `person` | `ExPipedrive.Person` |
  | `organization` | `ExPipedrive.Organization` |
  | `activity` | `ExPipedrive.Activity` |
  | `lead` | `ExPipedrive.Lead` |
  | `note` | `ExPipedrive.Note` |
  | `product` | `ExPipedrive.Product` |
  | `pipeline` | `ExPipedrive.Pipeline` |
  | `stage` | `ExPipedrive.Stage` |
  | `user` | `ExPipedrive.User` |
  | `activityType` | `ExPipedrive.ActivityType` |
  | `deal_product` | `ExPipedrive.DealProduct` |
  | `deal_installment` | `ExPipedrive.DealInstallment` |
  | `project` | `ExPipedrive.Project` |
  | `task` | `ExPipedrive.Task` |
  | `board` | `ExPipedrive.ProjectBoard` |

  Unknown resources (e.g. `phase`) keep `current` / `previous` as maps. The full
  delivery is always available on `:raw`. Deletes typically have `current: nil`
  and a populated `previous` (decoded when typed).

  Event structs stay in core so API-only apps can decode webhook payloads
  without Plug. Mount `ExPipedriveWeb.Incoming.Handler` from the optional
  `ex_pipedrive_web` package to receive POSTs.
  """

  alias ExPipedrive.{
    Activity,
    ActivityType,
    Deal,
    DealInstallment,
    DealProduct,
    Lead,
    Note,
    Organization,
    Person,
    Pipeline,
    Product,
    Project,
    ProjectBoard,
    Stage,
    Task,
    User
  }

  @actions ~w(added created deleted updated merged create change delete)

  @decoders %{
    "deal" => Deal,
    "person" => Person,
    "organization" => Organization,
    "activity" => Activity,
    "lead" => Lead,
    "note" => Note,
    "product" => Product,
    "pipeline" => Pipeline,
    "stage" => Stage,
    "user" => User,
    "activityType" => ActivityType,
    "deal_product" => DealProduct,
    "deal_installment" => DealInstallment,
    "project" => Project,
    "task" => Task,
    "board" => ProjectBoard
  }

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

  @type resource_payload :: struct() | map() | nil

  @type t :: %__MODULE__{
          name: String.t(),
          action: String.t() | nil,
          resource: String.t() | nil,
          current: resource_payload(),
          previous: resource_payload(),
          meta: map(),
          diff: map(),
          raw: map()
        }

  @doc """
  Resource keys that decode into entity structs.

  Other resources remain maps on `:current` / `:previous`.
  """
  @spec typed_resources() :: [String.t()]
  def typed_resources, do: @decoders |> Map.keys() |> Enum.sort()

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
    Map.get(payload, "event") ||
      Map.get(payload, "event_name") ||
      Map.get(payload, "event_type") ||
      synthesize_name(payload)
  end

  defp synthesize_name(payload) do
    meta = Map.get(payload, "meta", %{})
    action = Map.get(meta, "action")
    resource = meta_resource(meta)

    if is_binary(action) and is_binary(resource) do
      "#{action}.#{resource}"
    end
  end

  defp event_parts(name, payload) do
    meta = Map.get(payload, "meta", %{})

    case String.split(name, ".", parts: 2) do
      [action, resource] when action in @actions -> {action, resource}
      [resource, action] when action in @actions -> {action, resource}
      _ -> {Map.get(meta, "action"), meta_resource(meta)}
    end
  end

  defp meta_resource(meta) when is_map(meta) do
    Map.get(meta, "entity") || Map.get(meta, "object")
  end

  defp decode(_resource, nil), do: nil

  defp decode(resource, payload) when is_map(payload) do
    case Map.get(@decoders, resource) do
      nil -> payload
      module -> module.new(payload)
    end
  end

  defp decode(_resource, payload), do: payload

  defp diff(current, previous) when is_map(current) and is_map(previous) do
    Map.filter(current, fn {key, value} -> Map.get(previous, key) != value end)
  end

  defp diff(_, _), do: %{}
end
