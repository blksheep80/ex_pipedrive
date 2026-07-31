defmodule ExPipedrive.Fixtures.V2Followers do
  @moduledoc false

  @entity_id_key %{"deals" => "deal_id", "persons" => "person_id", "organizations" => "org_id"}

  def follower(segment, entity_id, id, user_id) do
    %{
      "id" => id,
      "user_id" => user_id,
      Map.fetch!(@entity_id_key, segment) => entity_id,
      "add_time" => "2024-01-01T00:00:00Z"
    }
  end

  def list_response(segment, entity_id, followers, opts \\ []) do
    %{
      "success" => true,
      "data" =>
        Enum.map(followers, fn {id, user_id} -> follower(segment, entity_id, id, user_id) end),
      "additional_data" => %{
        "next_cursor" => Keyword.get(opts, :next_cursor)
      }
    }
  end

  def add_response(segment, entity_id, id, user_id) do
    %{"success" => true, "data" => follower(segment, entity_id, id, user_id)}
  end

  def delete_response(segment, entity_id, id, user_id) do
    %{"success" => true, "data" => follower(segment, entity_id, id, user_id)}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-#{status}"}
  end
end
