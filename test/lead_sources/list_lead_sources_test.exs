defmodule ExPipedrive.LeadSources.ListLeadSourcesTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.LeadSource
  alias ExPipedrive.LeadSources

  describe "list/1" do
    test "returns all fixed lead sources", %{client: client} do
      assert {:ok, sources} = LeadSources.list(client)

      assert [%LeadSource{name: "Manually created"}, %LeadSource{name: "Deal"} | _] = sources
      assert Enum.any?(sources, &(&1.name == "API"))
    end
  end
end
