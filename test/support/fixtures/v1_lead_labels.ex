defmodule ExPipedrive.Fixtures.V1LeadLabels do
  @moduledoc false

  def label(id, name, color \\ "green") do
    %{"id" => id, "name" => name, "color" => color}
  end

  def list_response do
    %{
      "success" => true,
      "data" => [
        label("adf21080-0e10-11eb-879b-05d71fb426ec", "Hot", "red"),
        label("b1234080-0e10-11eb-879b-05d71fb426ec", "Warm", "yellow")
      ]
    }
  end

  def create_response(%{"name" => name} = attrs) do
    %{
      "success" => true,
      "data" =>
        label("c9999080-0e10-11eb-879b-05d71fb426ec", name, Map.get(attrs, "color", "green"))
    }
  end

  def update_response(id, attrs) do
    %{"success" => true, "data" => Map.merge(label(id, "Hot", "red"), attrs)}
  end

  def delete_response(id) do
    %{"success" => true, "data" => %{"id" => id}}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-#{status}"}
  end
end
