defmodule ExPipedrive.Fixtures.V2PersonLabels do
  @moduledoc false

  def option(id, label, color \\ "green") do
    %{
      "id" => id,
      "label" => label,
      "color" => color,
      "add_time" => "2024-01-01T00:00:00Z",
      "update_time" => "2024-01-01T00:00:00Z"
    }
  end

  def field_response do
    %{
      "success" => true,
      "data" => %{
        "field_code" => "label_ids",
        "field_name" => "Labels",
        "field_type" => "set",
        "options" => [
          option(1, "Customer", "green"),
          option(2, "Lead", "yellow")
        ]
      },
      "additional_data" => nil
    }
  end

  def add_options_response(options) when is_list(options) do
    %{
      "success" => true,
      "data" =>
        Enum.map(options, fn %{"label" => label} = attrs ->
          option(99, label, Map.get(attrs, "color", "green"))
        end),
      "additional_data" => nil
    }
  end

  def update_options_response(options) when is_list(options) do
    %{
      "success" => true,
      "data" =>
        Enum.map(options, fn %{"id" => id} = attrs ->
          option(id, Map.get(attrs, "label", "Customer"), Map.get(attrs, "color", "green"))
        end),
      "additional_data" => nil
    }
  end

  def delete_options_response(options) when is_list(options) do
    %{
      "success" => true,
      "data" => Enum.map(options, fn %{"id" => id} -> option(id, "Customer", "green") end),
      "additional_data" => nil
    }
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-#{status}"}
  end
end
