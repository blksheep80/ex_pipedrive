defmodule ExPipedrive.Page do
  @moduledoc """
  A single cursor-paginated page of Pipedrive API v2 results.

  Prefer this over bare lists for v2 list endpoints so callers can follow
  `next_cursor` (or use `ExPipedrive.Cursor.stream/2`).

  ## List return conventions

  | API style | Preferred return | Stream |
  |---|---|---|
  | v2 cursor | `{:ok, %Page{}}` via `list_page/2` | `stream/2` |
  | v1 offset | `{:ok, %ExPipedrive.PagedResult{}}` via `list/2` | optional |
  | Fixed / tiny collections (no pagination) | `{:ok, list}` | n/a |

  Avoid helpers that return a bare list when the underlying endpoint is
  paginated — see `ExPipedrive.Notes.get_all_org_notes/2` (now a `PagedResult`
  wrapper) and soft-deprecated `ExPipedrive.Pipelines.list_pipelines/1`.
  """

  use TypedStruct

  typedstruct do
    field :data, list(), default: []
    field :next_cursor, String.t() | nil
    field :limit, pos_integer() | nil
  end

  @doc """
  Builds a page from decoded entities and a raw API response body.
  """
  @spec from_items(list(), map()) :: t()
  def from_items(items, body) when is_list(items) and is_map(body) do
    additional = Map.get(body, "additional_data") || %{}

    %__MODULE__{
      data: items,
      next_cursor: Map.get(additional, "next_cursor"),
      limit: Map.get(additional, "limit")
    }
  end

  @doc """
  True when there is no further page to fetch.
  """
  @spec done?(t()) :: boolean()
  def done?(%__MODULE__{next_cursor: nil}), do: true
  def done?(%__MODULE__{}), do: false
end
