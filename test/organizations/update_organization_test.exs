defmodule ExPipedrive.Organizations.UpdateOrganizationTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase

  alias ExPipedrive.{
    Organization,
    Organizations
  }

  describe "update_organization" do
    test "it forms a PUT request and returns the results of the updated organization",
         %{client: client} do
      assert {:ok, %Organization{id: 5, name: "Org"}} =
               Organizations.update_organization(client, 5, %{
                 "93fc28f7d5aee87fc6484441cab648760a6c0d2d" => "Elixir"
               })
    end
  end
end
