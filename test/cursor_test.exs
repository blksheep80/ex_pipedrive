defmodule ExPipedrive.CursorTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Cursor
  alias ExPipedrive.Error
  alias ExPipedrive.Page

  describe "clamp_limit/1" do
    test "defaults and clamps to the Pipedrive v2 max of 500" do
      assert Cursor.clamp_limit(nil) == 100
      assert Cursor.clamp_limit(50) == 50
      assert Cursor.clamp_limit(500) == 500
      assert Cursor.clamp_limit(501) == 500
      assert Cursor.max_limit() == 500
    end
  end

  describe "stream/2" do
    test "follows cursors across pages and stops when next_cursor is nil" do
      fetch = fn
        [cursor: nil, limit: 100] ->
          {:ok, %Page{data: [1, 2], next_cursor: "page-2"}}

        [cursor: "page-2", limit: 100] ->
          {:ok, %Page{data: [3], next_cursor: nil}}
      end

      assert [1, 2, 3] == fetch |> Cursor.stream() |> Enum.to_list()
    end

    test "terminates on an empty final page" do
      fetch = fn
        [cursor: nil, limit: 10] ->
          {:ok, %Page{data: [:a], next_cursor: "empty"}}

        [cursor: "empty", limit: 10] ->
          {:ok, %Page{data: [], next_cursor: nil}}
      end

      assert [:a] == fetch |> Cursor.stream(limit: 10) |> Enum.to_list()
    end

    test "raises ExPipedrive.Error when a page fetch fails" do
      fetch = fn _opts ->
        {:error, %Error{kind: :rate_limited, status: 429, message: "slow down"}}
      end

      assert_raise Error, fn ->
        fetch |> Cursor.stream() |> Enum.to_list()
      end
    end
  end

  describe "Page" do
    test "from_items/2 reads next_cursor and done?/1" do
      page =
        Page.from_items([:x], %{
          "additional_data" => %{"next_cursor" => "abc", "limit" => 50}
        })

      assert page.data == [:x]
      assert page.next_cursor == "abc"
      assert page.limit == 50
      refute Page.done?(page)
      assert Page.done?(%Page{data: [], next_cursor: nil})
    end
  end
end
