defmodule ExPipedrive.Fixtures.V1DealParticipants do
  @moduledoc false

  def participant(id, deal_id, person_id) do
    %{
      "id" => id,
      "deal_id" => deal_id,
      "person_id" => person_id,
      "active_flag" => true,
      "created_by_user_id" => 123,
      "add_time" => "2024-01-01T00:00:00Z"
    }
  end

  def list_response(deal_id) do
    %{
      "success" => true,
      "data" => [participant(1, deal_id, 101), participant(2, deal_id, 102)],
      "additional_data" => %{
        "pagination" => %{"start" => 0, "limit" => 100, "more_items_in_collection" => false}
      }
    }
  end

  def add_response(deal_id, person_id) do
    %{"success" => true, "data" => participant(3, deal_id, person_id)}
  end

  def delete_response(deal_id, deal_participant_id) do
    %{"success" => true, "data" => %{"id" => deal_participant_id, "deal_id" => deal_id}}
  end
end
