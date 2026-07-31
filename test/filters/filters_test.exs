defmodule ExPipedrive.FiltersTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.Filter
  alias ExPipedrive.Filters

  @conditions %{
    "glue" => "and",
    "conditions" => [
      %{
        "glue" => "and",
        "conditions" => [
          %{
            "object" => "deal",
            "field_id" => 12_456,
            "operator" => ">",
            "value" => 1000,
            "extra_value" => nil
          }
        ]
      },
      %{"glue" => "or", "conditions" => []}
    ]
  }

  describe "list/2" do
    test "lists API v1 filters", %{client: client} do
      assert {:ok,
              [
                %Filter{
                  id: 1,
                  name: "High value deals",
                  type: "deals",
                  active_flag: true,
                  conditions: %{"glue" => "and"}
                }
              ]} = Filters.list(client)
    end

    test "scopes filters by :type", %{client: client} do
      assert {:ok, []} = Filters.list(client, type: "leads")
    end
  end

  describe "get/2" do
    test "fetches a filter by id", %{client: client} do
      assert {:ok, %Filter{id: 1, name: "High value deals", type: "deals"}} =
               Filters.get(client, 1)
    end

    test "maps missing filters to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Filters.get(client, 404)
    end
  end

  describe "create/2" do
    test "creates a filter through POST /api/v1/filters", %{client: client} do
      assert {:ok,
              %Filter{
                name: "Stale deals",
                type: "deals",
                conditions: %{"glue" => "and"}
              }} =
               Filters.create(client, %{
                 name: "Stale deals",
                 type: "deals",
                 conditions: @conditions,
                 ignored: "not sent"
               })
    end
  end

  describe "update/3" do
    test "updates a filter through PUT /api/v1/filters/:id", %{client: client} do
      assert {:ok, %Filter{id: 1, name: "Renamed filter"}} =
               Filters.update(client, 1, %{name: "Renamed filter"})
    end

    test "maps missing filters to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Filters.update(client, 404, %{name: "Nope"})
    end
  end

  describe "delete/2" do
    test "deletes a filter through DELETE /api/v1/filters/:id", %{client: client} do
      assert {:ok, :ok} = Filters.delete(client, 1)
    end

    test "maps missing filters to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Filters.delete(client, 404)
    end
  end
end
