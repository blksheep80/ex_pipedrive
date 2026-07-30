defmodule ExPipedrive.Organizations.StreamOrganizationsTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Organization
  alias ExPipedrive.Organizations
  alias ExPipedrive.Page

  test "list_organizations_page/2 and stream_organizations/2 follow cursors", %{client: client} do
    assert {:ok, %Page{data: [org1 | _], next_cursor: "orgs-page-2"}} =
             Organizations.list_organizations_page(client)

    assert %Organization{id: 1} = org1

    orgs = client |> Organizations.stream_organizations() |> Enum.to_list()
    assert Enum.map(orgs, & &1.id) == [1, 2, 3]
  end
end
