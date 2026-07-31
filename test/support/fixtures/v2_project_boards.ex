defmodule ExPipedrive.Fixtures.V2ProjectBoards do
  @moduledoc false

  def board(id \\ 1, overrides \\ %{}) do
    Map.merge(
      %{
        "id" => id,
        "name" => "Project Board",
        "order_nr" => id,
        "add_time" => "2024-01-01T00:00:00.000Z",
        "update_time" => "2024-01-01T00:00:00.000Z"
      },
      overrides
    )
  end

  def get_response(id \\ 1) do
    %{"success" => true, "data" => board(id)}
  end

  def list_response do
    %{
      "success" => true,
      "data" => [board(1), board(2, %{"name" => "Second board"})],
      "additional_data" => nil
    }
  end

  def create_response(attrs) when is_map(attrs) do
    base = board(99)

    data =
      Map.merge(base, %{
        "name" => Map.get(attrs, "name", base["name"]),
        "order_nr" => Map.get(attrs, "order_nr", base["order_nr"])
      })

    %{"success" => true, "data" => data}
  end

  def update_response(id, attrs) when is_map(attrs) do
    %{"success" => true, "data" => Map.merge(board(id), attrs)}
  end

  def delete_response(id) do
    %{"success" => true, "data" => %{"id" => id}}
  end

  def error_response(status, message) do
    %{"success" => false, "error" => message, "error_info" => "fake-board-v2-#{status}"}
  end
end
