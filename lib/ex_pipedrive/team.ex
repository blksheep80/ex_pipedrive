defmodule ExPipedrive.Team do
  @moduledoc """
  A Pipedrive legacy team (`/api/v1/legacyTeams`).

  Pipedrive renamed the former `/api/v1/teams` path to `legacyTeams` while
  preparing a replacement Teams API; scopes and behaviour are unchanged.
  """

  use TypedStruct
  use ExPipedrive.Structable

  typedstruct do
    field :id, pos_integer()
    field :name, String.t()
    field :description, String.t()
    field :manager_id, pos_integer()
    field :users, list(pos_integer()), default: []
    field :active_flag, boolean(), default: true
    field :deleted_flag, boolean(), default: false
    field :add_time, DateTime.t() | NaiveDateTime.t()
    field :created_by_user_id, pos_integer()
    field :original_object, map()
  end

  def handle_transform(map, original) do
    map
    |> Map.update(:users, [], &(&1 || []))
    |> Map.update(:active_flag, true, &truthy?/1)
    |> Map.update(:deleted_flag, false, &truthy?/1)
    |> Map.update(:add_time, nil, &parse_datetime/1)
    |> Map.put(:original_object, original)
  end

  defp truthy?(true), do: true
  defp truthy?(1), do: true
  defp truthy?("1"), do: true
  defp truthy?(false), do: false
  defp truthy?(0), do: false
  defp truthy?("0"), do: false
  defp truthy?(other), do: other
end
