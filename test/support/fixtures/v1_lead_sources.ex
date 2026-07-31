defmodule ExPipedrive.Fixtures.V1LeadSources do
  @moduledoc false

  def list_response do
    %{
      "success" => true,
      "data" => [
        %{"name" => "Manually created"},
        %{"name" => "Deal"},
        %{"name" => "Web forms"},
        %{"name" => "API"}
      ]
    }
  end
end
