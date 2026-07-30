defmodule ExPipedrive.Deals.DealsV2Test do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Deal
  alias ExPipedrive.Deals
  alias ExPipedrive.Error

  describe "get/2" do
    test "returns a typed Deal from v2", %{client: client} do
      assert {:ok, %Deal{id: 1, title: "Mecklem, LLC deal", person_id: 1, custom_fields: fields}} =
               Deals.get(client, 1)

      assert is_map(fields)
      assert map_size(fields) > 0
    end

    test "maps missing deals to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Deals.get(client, 404)
    end
  end

  describe "create/2" do
    test "creates from a map and returns a Deal", %{client: client} do
      assert {:ok, %Deal{id: 99, title: "New deal", person_id: 7, value: 1000.0}} =
               Deals.create(client, %{
                 title: "New deal",
                 person_id: 7,
                 value: 1000.0,
                 currency: "USD"
               })
    end

    test "creates from a Deal struct write attrs", %{client: client} do
      assert {:ok, %Deal{id: 99, title: "From struct"}} =
               Deals.create(client, %Deal{title: "From struct", person_id: 1})
    end
  end

  describe "update/3" do
    test "patches a deal and returns the updated Deal", %{client: client} do
      assert {:ok, %Deal{id: 1, title: "Updated title", status: "won"}} =
               Deals.update(client, 1, %{title: "Updated title", status: "won"})
    end
  end

  describe "delete/2" do
    test "deletes a deal", %{client: client} do
      assert {:ok, %{"success" => true, "data" => %{"id" => 1}}} = Deals.delete(client, 1)
    end

    test "maps missing deletes to structured errors", %{client: client} do
      assert {:error, %Error{status: 404}} = Deals.delete(client, 404)
    end
  end

  describe "stream/2 alias" do
    test "streams open deals via the MVP-friendly name", %{client: client} do
      deals = client |> Deals.stream(status: "open", limit: 500) |> Enum.to_list()
      assert Enum.map(deals, & &1.id) == [1, 2, 3]
    end
  end
end
