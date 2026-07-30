defmodule ExPipedrive.Search.SearchV2Test do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Deal
  alias ExPipedrive.Error
  alias ExPipedrive.Organization
  alias ExPipedrive.Page
  alias ExPipedrive.Person
  alias ExPipedrive.Search
  alias ExPipedrive.SearchResult

  describe "search_page/3" do
    test "unwraps items and returns a Page of SearchResults", %{client: client} do
      assert {:ok, %Page{data: [result], next_cursor: nil, limit: 100}} =
               Search.search_page(client, "great")

      assert %SearchResult{type: "deal", result_score: score, item: %Deal{id: 2, title: title}} =
               result

      assert is_float(score) or is_integer(score)
      assert title == "Great Amazing Deal"
    end

    test "paginates when multiple items match", %{client: client} do
      assert {:ok, %Page{data: [_first], next_cursor: "search-page-2"}} =
               Search.search_page(client, "mecklem")

      assert {:ok, %Page{data: rest, next_cursor: nil}} =
               Search.search_page(client, "mecklem", cursor: "search-page-2")

      assert length(rest) >= 1
      assert Enum.all?(rest, &match?(%SearchResult{}, &1))
    end

    test "filters by item_types list", %{client: client} do
      assert {:ok, %Page{data: results, next_cursor: nil}} =
               Search.search_page(client, "mecklem", item_types: ["organization"])

      assert [%SearchResult{type: "organization", item: %Organization{name: "Mecklem, LLC"}}] =
               results
    end

    test "maps API errors to structured Error", %{client: client} do
      assert {:error, %Error{status: 400}} =
               Search.search_page(client, "__http_400__")
    end
  end

  describe "typed helpers" do
    test "search_deals/3 scopes to deals", %{client: client} do
      assert {:ok, %Page{data: [%SearchResult{type: "deal", item: %Deal{id: 2}}]}} =
               Search.search_deals(client, "great")
    end

    test "search_persons/3 scopes to persons", %{client: client} do
      assert {:ok,
              %Page{data: [%SearchResult{type: "person", item: %Person{name: "Tim Mecklem"}}]}} =
               Search.search_persons(client, "tim")
    end

    test "search_organizations/3 scopes to organizations", %{client: client} do
      assert {:ok,
              %Page{
                data: [
                  %SearchResult{type: "organization", item: %Organization{name: "Mecklem, LLC"}}
                ]
              }} =
               Search.search_organizations(client, "mecklem")
    end
  end

  describe "stream/3" do
    test "follows next_cursor until exhausted", %{client: client} do
      results = client |> Search.stream("mecklem", limit: 100) |> Enum.to_list()

      types = Enum.map(results, & &1.type)
      assert "deal" in types or "person" in types or "organization" in types
      assert Enum.all?(results, &match?(%SearchResult{}, &1))
      assert length(results) >= 2
    end
  end

  describe "limit clamping" do
    test "clamps limit to 100", %{client: client} do
      assert Search.max_limit() == 100

      assert {:ok, %Page{limit: 100}} =
               Search.search_page(client, "great", limit: 500)
    end
  end
end
