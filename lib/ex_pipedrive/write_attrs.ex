defmodule ExPipedrive.WriteAttrs do
  @moduledoc """
  Normalizes write payloads for Pipedrive create/update calls.

  Used by resource modules and by host apps implementing
  `ExPipedrive.Resource.encode/1`.
  """

  @doc """
  Normalizes a map or struct into a string-keyed map limited to `allowed` keys.

  Drops `:original_object` from structs.
  """
  def take(attrs, allowed) when is_map(attrs) and is_list(allowed) do
    attrs
    |> normalize_keys()
    |> Map.take(allowed)
  end

  defp normalize_keys(%{__struct__: _} = struct) do
    struct
    |> Map.from_struct()
    |> Map.drop([:__struct__, :original_object])
    |> normalize_keys()
  end

  defp normalize_keys(map) do
    Map.new(map, fn
      {key, value} when is_atom(key) -> {Atom.to_string(key), value}
      {key, value} when is_binary(key) -> {key, value}
    end)
  end
end
