defmodule ExPipedrive.PipelineTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Pipeline

  test "decodes v2 pipeline fields" do
    pipeline =
      Pipeline.new(%{
        "id" => 1,
        "name" => "Sales",
        "order_nr" => 1,
        "is_deleted" => false,
        "is_deal_probability_enabled" => true,
        "add_time" => "2024-01-01T00:00:00Z",
        "update_time" => "2024-01-01T00:00:00Z"
      })

    assert %Pipeline{
             id: 1,
             name: "Sales",
             is_deleted: false,
             is_deal_probability_enabled: true,
             active: true,
             deal_probability: true
           } = pipeline
  end

  test "maps v1 active/deal_probability onto v2 flags" do
    pipeline =
      Pipeline.new(%{
        "id" => 1,
        "name" => "Pipeline",
        "url_title" => "default",
        "order_nr" => 1,
        "active" => true,
        "deal_probability" => false,
        "add_time" => "2022-07-08 12:08:35",
        "update_time" => nil,
        "selected" => true
      })

    assert %Pipeline{
             is_deleted: false,
             is_deal_probability_enabled: false,
             active: true,
             deal_probability: false,
             url_title: "default"
           } = pipeline
  end
end
