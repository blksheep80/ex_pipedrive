defmodule ExPipedrive.Fixtures.V2ItemSearch do
  @moduledoc false

  def deal_item(id \\ 2) do
    %{
      "result_score" => 1.092828,
      "item" => %{
        "id" => id,
        "type" => "deal",
        "title" => "Great Amazing Deal",
        "value" => 40_000,
        "currency" => "USD",
        "status" => "open",
        "visible_to" => 3,
        "owner" => %{"id" => 15_783_886},
        "stage" => %{"id" => 7, "name" => "Qualified"},
        "person" => %{"id" => 1, "name" => "Tim Mecklem"},
        "organization" => %{"id" => 1, "name" => "Mecklem, LLC", "address" => nil},
        "custom_fields" => [],
        "notes" => []
      }
    }
  end

  def person_item(id \\ 1) do
    %{
      "result_score" => 0.35513008,
      "item" => %{
        "id" => id,
        "type" => "person",
        "name" => "Tim Mecklem",
        "phones" => ["555-1111"],
        "emails" => ["tim@example.com"],
        "visible_to" => 3,
        "owner" => %{"id" => 15_783_886},
        "organization" => %{
          "id" => 1,
          "name" => "Mecklem, LLC",
          "address" => nil
        },
        "custom_fields" => [],
        "notes" => []
      }
    }
  end

  def organization_item(id \\ 1) do
    %{
      "result_score" => 0.88,
      "item" => %{
        "id" => id,
        "type" => "organization",
        "name" => "Mecklem, LLC",
        "address" => nil,
        "visible_to" => 3,
        "owner" => %{"id" => 15_783_886},
        "custom_fields" => [],
        "notes" => []
      }
    }
  end

  def search_response(term, params \\ %{}) do
    items = filter_items(term, Map.get(params, "item_types"))
    {page_items, next_cursor} = paginate(items, Map.get(params, "cursor"))

    %{
      "success" => true,
      "data" => %{"items" => page_items},
      "additional_data" => %{
        "next_cursor" => next_cursor,
        "limit" => parse_limit(Map.get(params, "limit"))
      }
    }
  end

  def error_response(status, message) do
    %{
      "success" => false,
      "error" => message,
      "error_info" => "fake itemSearch error #{status}",
      "data" => nil
    }
  end

  defp filter_items(term, item_types) do
    term_lc = String.downcase(to_string(term || ""))

    all = [deal_item(), person_item(), organization_item()]

    all
    |> Enum.filter(fn %{"item" => item} ->
      type_ok?(item["type"], item_types) and term_matches?(item, term_lc)
    end)
  end

  defp type_ok?(_type, nil), do: true
  defp type_ok?(_type, ""), do: true

  defp type_ok?(type, csv) when is_binary(csv) do
    csv
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.member?(type)
  end

  defp term_matches?(_item, ""), do: true

  defp term_matches?(item, term_lc) do
    haystacks =
      [
        item["title"],
        item["name"],
        get_in(item, ["organization", "name"]),
        get_in(item, ["person", "name"])
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&String.downcase/1)

    Enum.any?(haystacks, &String.contains?(&1, term_lc))
  end

  defp paginate(items, nil) do
    case items do
      [first | rest] when rest != [] -> {[first], "search-page-2"}
      other -> {other, nil}
    end
  end

  defp paginate(items, "search-page-2") do
    case items do
      [_first | rest] -> {rest, nil}
      _ -> {[], nil}
    end
  end

  defp paginate(_items, _), do: {[], nil}

  defp parse_limit(nil), do: 100

  defp parse_limit(limit) when is_binary(limit) do
    case Integer.parse(limit) do
      {int, _} -> int
      :error -> 100
    end
  end

  defp parse_limit(limit) when is_integer(limit), do: limit
  defp parse_limit(_), do: 100
end
