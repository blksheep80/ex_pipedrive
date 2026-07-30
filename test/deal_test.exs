defmodule ExPipedrive.DealTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Deal

  describe "new/1" do
    test "it accepts string keys" do
      assert %Deal{id: 45} = Deal.new(%{"id" => 45})
    end

    test "it accepts atom keys" do
      assert %Deal{id: 45} = Deal.new(%{id: 45})
    end
  end
end
