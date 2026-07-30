defmodule ExPipedrive.FakeServer.V2FixturesTest do
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Activity
  alias ExPipedrive.Deal
  alias ExPipedrive.Error
  alias ExPipedrive.Person
  alias ExPipedrive.Request
  alias ExPipedrive.Response

  describe "v2 deals fixtures" do
    test "get deal returns v2 shape that Deal.new/1 understands", %{client: client} do
      assert {:ok, deal} =
               client
               |> Request.get("deals/:id", opts: [path_params: [id: 1]])
               |> Response.map([200], fn %{body: %{"data" => data}} -> Deal.new(data) end)

      assert deal.id == 1
      assert deal.owner_id == 15_783_886
      assert deal.person_id == 1
      assert deal.org_id == 1
      assert deal.custom_fields["53c2f18db6a1655d6af8bba77d9679565f975fd8"] == "Text Custom Field"
      assert %DateTime{} = deal.add_time
      assert deal.original_object["is_deleted"] == false
    end

    test "list deals returns cursor pagination", %{client: client} do
      assert {:ok, %{body: body}} = Request.get(client, "deals")
      assert body["additional_data"]["next_cursor"] == "cursor-page-2"
      assert length(body["data"]) == 2

      assert {:ok, %{body: page2}} =
               Request.get(client, "deals", query: [cursor: "cursor-page-2"])

      assert page2["additional_data"]["next_cursor"] == nil
      assert length(page2["data"]) == 1
    end

    test "create deal returns 201 v2 payload", %{client: client} do
      assert {:ok, deal} =
               client
               |> Request.post("deals", %{"title" => "New deal", "person_id" => 1})
               |> Response.map([201], fn %{body: %{"data" => data}} -> Deal.new(data) end)

      assert deal.id == 99
      assert deal.title == "New deal"
      assert deal.person_id == 1
    end

    test "update deal patches fields", %{client: client} do
      assert {:ok, deal} =
               client
               |> Request.patch("deals/:id", %{"title" => "Updated"},
                 opts: [path_params: [id: 1]]
               )
               |> Response.map([200], fn %{body: %{"data" => data}} -> Deal.new(data) end)

      assert deal.title == "Updated"
    end
  end

  describe "v2 persons fixtures" do
    test "get person returns v2 shape that Person.new/1 understands", %{client: client} do
      assert {:ok, person} =
               client
               |> Request.get("persons/:id", opts: [path_params: [id: 1]])
               |> Response.map([200], fn %{body: %{"data" => data}} -> Person.new(data) end)

      assert person.id == 1
      assert person.owner_id == 15_783_886
      assert person.org_id == 1
      assert person.primary_email == "tim@launchscout.com"
      assert person.custom_fields["53c2f18db6a1655d6af8bba77d9679565f975fd8"] == "VIP"
      assert %DateTime{} = person.add_time
    end

    test "list persons returns cursor pagination", %{client: client} do
      assert {:ok, %{body: body}} = Request.get(client, "persons")
      assert body["additional_data"]["next_cursor"] == "persons-page-2"
      assert length(body["data"]) == 2
    end

    test "create person returns 201 v2 payload", %{client: client} do
      assert {:ok, person} =
               client
               |> Request.post("persons", %{"name" => "Ada Lovelace"})
               |> Response.map([201], fn %{body: %{"data" => data}} -> Person.new(data) end)

      assert person.id == 99
      assert person.name == "Ada Lovelace"
    end
  end

  describe "v2 activities fixtures" do
    test "get activity returns v2 shape that Activity.new/1 understands", %{client: client} do
      assert {:ok, activity} =
               client
               |> Request.get("activities/:id", opts: [path_params: [id: 1]])
               |> Response.map([200], fn %{body: %{"data" => data}} -> Activity.new(data) end)

      assert activity.id == 1
      assert activity.owner_id == 15_783_886
      assert activity.deal_id == 1
      assert activity.location == "123 Main St, Cincinnati, OH 45202"
      assert activity.busy_flag == true
      assert activity.custom_fields["53c2f18db6a1655d6af8bba77d9679565f975fd8"] == "Follow-up"
      assert %DateTime{} = activity.add_time
      assert activity.original_object["is_deleted"] == false
    end

    test "list activities returns cursor pagination", %{client: client} do
      assert {:ok, %{body: body}} = Request.get(client, "activities")
      assert body["additional_data"]["next_cursor"] == "activities-page-2"
      assert length(body["data"]) == 2

      assert {:ok, %{body: page2}} =
               Request.get(client, "activities", query: [cursor: "activities-page-2"])

      assert page2["additional_data"]["next_cursor"] == nil
      assert length(page2["data"]) == 1
    end

    test "create activity returns 201 v2 payload", %{client: client} do
      assert {:ok, activity} =
               client
               |> Request.post("activities", %{"subject" => "New call", "type" => "call"})
               |> Response.map([201], fn %{body: %{"data" => data}} -> Activity.new(data) end)

      assert activity.id == 99
      assert activity.subject == "New call"
    end

    test "update activity patches fields", %{client: client} do
      assert {:ok, activity} =
               client
               |> Request.patch("activities/:id", %{"subject" => "Updated"},
                 opts: [path_params: [id: 1]]
               )
               |> Response.map([200], fn %{body: %{"data" => data}} -> Activity.new(data) end)

      assert activity.subject == "Updated"
    end
  end

  describe "v2 error fixtures" do
    test "maps 404/401/429 into ExPipedrive.Error", %{client: client} do
      assert {:error, %Error{kind: :not_found, status: 404, request_id: "fake-deal-v2-error"}} =
               client
               |> Request.get("deals/:id", opts: [path_params: [id: 404]])
               |> Response.map([200], fn env -> env end)

      assert {:error, %Error{kind: :unauthorized, status: 401}} =
               client
               |> Request.get("deals", query: [error: "401"])
               |> Response.map([200], fn env -> env end)

      assert {:error, %Error{kind: :rate_limited, status: 429}} =
               client
               |> Request.get("persons", query: [error: "429"])
               |> Response.map([200], fn env -> env end)

      assert {:error, %Error{kind: :validation, status: 400}} =
               client
               |> Request.get("deals", query: [error: "400"])
               |> Response.map([200], fn env -> env end)
    end
  end
end
