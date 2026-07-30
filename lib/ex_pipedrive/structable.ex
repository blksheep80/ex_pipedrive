defmodule LineDrive.Structable do
  @moduledoc """
  This module can be imported/used by other modules that have structs defined
  and need to process the input of a map or nested maps in order to construct
  the struct(s). It provides helper fucntions to atomize the map keys from
  expected struct fields (without blanket atomizing everything in the input
  map). It also provides some date/time and other utility funtions for parsing
  data out of maps built from json responses.
  """

  defmacro __using__(_) do
    quote do
      import LineDrive.Structable

      def new(map), do: new_from_map(map)

      def new_from_map(map) when is_map(map) do
        map
        |> atomize_keys()
        |> handle_transform(map)
        |> then(&struct(__MODULE__, &1))
      end

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

      defp parse_datetime(date_str) do
        case NaiveDateTime.from_iso8601(date_str) do
          {:ok, date} -> date
          _ -> nil
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

      defp parse_integer(visible_to) when is_binary(visible_to), do: String.to_integer(visible_to)

      defp parse_integer(visible_to), do: visible_to

      defp handle_transform(atomized_map, _original_map), do: atomized_map

      defoverridable new: 1, handle_transform: 2
    end
  end
end
