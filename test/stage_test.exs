defmodule ExPipedrive.StageTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Stage

  test "decodes v2 stage fields" do
    stage =
      Stage.new(%{
        "id" => 2,
        "order_nr" => 2,
        "name" => "Contact Made",
        "is_deleted" => false,
        "deal_probability" => 40,
        "pipeline_id" => 1,
        "is_deal_rot_enabled" => false,
        "days_to_rotten" => nil,
        "add_time" => "2024-01-01T00:00:00Z",
        "update_time" => "2024-01-02T00:00:00Z"
      })

    assert %Stage{
             id: 2,
             name: "Contact Made",
             pipeline_id: 1,
             deal_probability: 40,
             is_deal_rot_enabled: false,
             days_to_rotten: nil,
             is_deleted: false
           } = stage
  end
end
