defmodule ExPipedrive.Structable do
  @moduledoc """
  Helpers for building entity structs from Pipedrive JSON maps.

  Atomizes only known struct keys (no blanket atomization), normalizes nested
  v1 ID objects to integers, parses v1 and v2 timestamps, and preserves the
  raw payload via `original_object` when entities opt in.
  """

  defmacro __using__(_) do
    quote do
      import ExPipedrive.Structable

      def new(map), do: new(map, [])

      def new(map, opts) when is_map(map) and is_list(opts) do
        map
        |> atomize_keys()
        |> handle_transform(map, opts)
        |> then(&struct(__MODULE__, &1))
      end

      def new(nil, _opts), do: nil

      def new_from_map(map) when is_map(map), do: new(map, [])
      def new_from_map(nil), do: nil

      defp atomize_keys(map) do
        struct_keys()
        |> Enum.reduce(%{}, fn key, acc ->
          Map.put(
            acc,
            key,
            Map.get_lazy(map, key, fn -> Map.get(map, Atom.to_string(key), nil) end)
          )
        end)
      end

      defp struct_keys do
        Map.keys(__MODULE__.__struct__())
        |> List.delete(:__struct__)
      end

      defp parse_date(date_str) when is_binary(date_str) do
        case Date.from_iso8601(date_str) do
          {:ok, date} -> date
          _ -> nil
        end
      end

      defp parse_date(date), do: date

      defp parse_datetime(nil), do: nil
      defp parse_datetime(%DateTime{} = datetime), do: datetime
      defp parse_datetime(%NaiveDateTime{} = datetime), do: datetime

      defp parse_datetime(date_str) when is_binary(date_str) do
        normalized =
          if String.contains?(date_str, " ") and not String.contains?(date_str, "T") do
            String.replace(date_str, " ", "T", global: false)
          else
            date_str
          end

        parse_iso_datetime(normalized)
      end

      defp parse_datetime(_), do: nil

      defp parse_iso_datetime(date_str) do
        case DateTime.from_iso8601(date_str) do
          {:ok, datetime, _offset} ->
            datetime

          {:error, _} ->
            case NaiveDateTime.from_iso8601(date_str) do
              {:ok, datetime} -> datetime
              _ -> nil
            end
        end
      end

      defp parse_time(val) when is_binary(val) do
        [hour, minute, second] =
          val
          |> String.split(":")
          |> Enum.map(&String.to_integer/1)

        case Time.new(hour, minute, second) do
          {:ok, date} -> date
          _ -> nil
        end
      end

      defp parse_time(_), do: nil

      defp get_nested_value(nil, _key), do: nil

      defp get_nested_value(map, key), do: Map.get(map, key, nil)

      @doc false
      defp normalize_id(nil), do: nil
      defp normalize_id(id) when is_integer(id), do: id

      defp normalize_id(id) when is_binary(id) do
        case Integer.parse(id) do
          {int, ""} -> int
          _ -> nil
        end
      end

      defp normalize_id(%{} = map) do
        cond do
          Map.has_key?(map, "value") -> normalize_id(Map.get(map, "value"))
          Map.has_key?(map, :value) -> normalize_id(Map.get(map, :value))
          Map.has_key?(map, "id") -> normalize_id(Map.get(map, "id"))
          Map.has_key?(map, :id) -> normalize_id(Map.get(map, :id))
          true -> nil
        end
      end

      defp normalize_id(_), do: nil

      defp extract_custom_fields(original_map) when is_map(original_map) do
        Map.get(original_map, "custom_fields") ||
          Map.get(original_map, :custom_fields) ||
          %{}
      end

      defp extract_custom_fields(_), do: %{}

      defp parse_integer(visible_to) when is_binary(visible_to), do: String.to_integer(visible_to)

      defp parse_integer(visible_to), do: visible_to

      defp handle_transform(atomized_map, original_map, _opts) do
        handle_transform(atomized_map, original_map)
      end

      defp handle_transform(atomized_map, _original_map), do: atomized_map

      defoverridable new: 1, new: 2, handle_transform: 2, handle_transform: 3
    end
  end
end
