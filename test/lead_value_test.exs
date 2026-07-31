defmodule ExPipedrive.LeadValueTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.LeadValue

  describe "new/1" do
    test "preserves the currency from an API map" do
      assert %LeadValue{amount: 150_000.0, currency: "EUR"} =
               LeadValue.new(%{"amount" => 150_000, "currency" => "EUR"})
    end

    test "does not infer a currency from a bare integer" do
      assert %LeadValue{amount: 150_000.0, currency: nil} = LeadValue.new(150_000)
    end

    test "returns nil for a nil value" do
      assert LeadValue.new(nil) == nil
    end
  end
end
