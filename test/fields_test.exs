defmodule ExPipedrive.FieldsTest do
  use ExUnit.Case, async: true

  alias ExPipedrive.Field
  alias ExPipedrive.Fields
  alias ExPipedrive.Page

  @code "a31aaf5e2c4843027e1e183d7001686afb9781d0"

  setup do
    fields = [
      Field.new(%{"field_code" => @code, "field_name" => "Customer tier"}),
      %{"field_code" => "region_hash", "field_name" => "Region"}
    ]

    %{fields: fields, page: %Page{data: fields}}
  end

  test "resolves a definition by its field code", %{page: page} do
    assert {:ok, %Field{field_code: @code, field_name: "Customer tier"}} =
             Fields.resolve(page, @code)
  end

  test "resolves a definition by its human-readable label", %{fields: fields} do
    assert {:ok, %Field{field_code: @code}} = Fields.resolve(fields, "Customer tier")
  end

  test "resolves field codes and labels from lists and maps", %{fields: fields, page: page} do
    assert {:ok, @code} = Fields.key_for(page, "Customer tier")
    assert {:ok, "Customer tier"} = Fields.label_for(fields, @code)

    field_map =
      Map.new(fields, fn field ->
        {Map.get(field, :field_code) || Map.get(field, "field_code"), field}
      end)

    assert {:ok, "Region"} = Fields.label_for(field_map, "region_hash")
  end

  test "returns :error when a field cannot be found", %{fields: fields} do
    assert :error = Fields.resolve(fields, "Missing field")
    assert :error = Fields.key_for(fields, "Missing field")
    assert :error = Fields.label_for(fields, "missing_hash")
  end
end
