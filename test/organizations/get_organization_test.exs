defmodule ExPipedrive.Organizations.GetOrganizationTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Organization
  alias ExPipedrive.Organizations

  describe "get_organization" do
    test "it forms a correct request and returns the organization when it exists", %{
      client: client
    } do
      assert {:ok, %Organization{id: 1}} = Organizations.get_organization(client, 1)
    end
  end
end
