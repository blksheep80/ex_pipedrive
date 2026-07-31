defmodule ExPipedrive.FollowersTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Follower
  alias ExPipedrive.Followers
  alias ExPipedrive.Page

  describe "deal followers" do
    test "list/add/delete via the generic API", %{client: client} do
      assert {:ok, %Page{data: [%Follower{id: 1, user_id: 456, deal_id: 1} | _]}} =
               Followers.list_page(client, :deal, 1)

      assert {:ok, %Follower{id: 3, user_id: 789, deal_id: 1}} =
               Followers.add(client, :deal, 1, 789)

      assert {:ok, %Follower{id: 1, deal_id: 1}} = Followers.delete(client, :deal, 1, 1)
    end

    test "list/add/delete via per-entity convenience wrappers", %{client: client} do
      assert {:ok, %Page{data: followers}} = Followers.list_deal_followers(client, 1)
      assert length(followers) == 2

      assert {:ok, %Follower{user_id: 789}} = Followers.add_deal_follower(client, 1, 789)
      assert {:ok, %Follower{id: 1}} = Followers.delete_deal_follower(client, 1, 1)
    end

    test "stream_deal_followers/3 lazily follows pages", %{client: client} do
      followers = client |> Followers.stream_deal_followers(1) |> Enum.to_list()
      assert length(followers) == 2
      assert Enum.all?(followers, &match?(%Follower{deal_id: 1}, &1))
    end
  end

  describe "person followers" do
    test "list/add/delete", %{client: client} do
      assert {:ok, %Page{data: [%Follower{person_id: 1} | _]}} =
               Followers.list_person_followers(client, 1)

      assert {:ok, %Follower{user_id: 789, person_id: 1}} =
               Followers.add_person_follower(client, 1, 789)

      assert {:ok, %Follower{id: 1, person_id: 1}} =
               Followers.delete_person_follower(client, 1, 1)
    end
  end

  describe "organization followers" do
    test "list/add/delete", %{client: client} do
      assert {:ok, %Page{data: [%Follower{org_id: 1} | _]}} =
               Followers.list_organization_followers(client, 1)

      assert {:ok, %Follower{user_id: 789, org_id: 1}} =
               Followers.add_organization_follower(client, 1, 789)

      assert {:ok, %Follower{id: 1, org_id: 1}} =
               Followers.delete_organization_follower(client, 1, 1)
    end
  end
end
