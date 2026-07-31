defmodule ExPipedrive.FakeFileApiHandler do
  @moduledoc false

  import Plug.Conn

  @sample_file %{
    "id" => 1,
    "user_id" => 1,
    "deal_id" => 1,
    "person_id" => nil,
    "org_id" => nil,
    "product_id" => nil,
    "activity_id" => nil,
    "lead_id" => nil,
    "project_id" => nil,
    "add_time" => "2024-06-01 12:00:00",
    "update_time" => "2024-06-01 12:00:00",
    "file_name" => "note.txt",
    "file_size" => 5,
    "file_type" => "txt",
    "active_flag" => true,
    "inline_flag" => false,
    "remote_location" => nil,
    "remote_id" => nil,
    "s3_bucket" => nil,
    "url" => "https://pipedrive-files.example/1/note.txt",
    "name" => "note.txt",
    "description" => nil
  }

  @download_body "hello"

  def handle_list_files(conn, params \\ %{}) do
    data =
      case Map.get(params, "deal_id") do
        "999" -> []
        _ -> [@sample_file]
      end

    json(conn, 200, %{
      "success" => true,
      "data" => data,
      "additional_data" => %{
        "pagination" => %{
          "start" => 0,
          "limit" => 100,
          "more_items_in_collection" => false
        }
      }
    })
  end

  def handle_get_file(conn, %{"id" => "1"}) do
    json(conn, 200, %{"success" => true, "data" => @sample_file})
  end

  def handle_get_file(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "File not found"})
  end

  def handle_download_file(conn, %{"id" => "1"}) do
    conn
    |> put_resp_header("content-type", "application/octet-stream")
    |> send_resp(200, @download_body)
  end

  def handle_download_file(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "File not found"})
  end

  def handle_upload_file(%{body_params: params} = conn) do
    {filename, size} = file_meta(params)

    file =
      @sample_file
      |> Map.put("file_name", filename)
      |> Map.put("name", filename)
      |> Map.put("file_size", size)
      |> put_link(params, "deal_id")
      |> put_link(params, "person_id")
      |> put_link(params, "org_id")
      |> put_link(params, "activity_id")
      |> put_link(params, "product_id")
      |> put_link(params, "lead_id")
      |> put_link(params, "project_id")

    json(conn, 201, %{"success" => true, "data" => file})
  end

  def handle_update_file(%{body_params: body, params: %{"id" => "1"}} = conn) do
    file =
      @sample_file
      |> Map.merge(Map.take(body, ["name", "description"]))

    json(conn, 200, %{"success" => true, "data" => file})
  end

  def handle_update_file(%{params: %{"id" => "404"}} = conn) do
    json(conn, 404, %{"success" => false, "error" => "File not found"})
  end

  def handle_delete_file(conn, %{"id" => "1"}) do
    json(conn, 200, %{"success" => true, "data" => %{"id" => 1}})
  end

  def handle_delete_file(conn, %{"id" => "404"}) do
    json(conn, 404, %{"success" => false, "error" => "File not found"})
  end

  def handle_create_remote_file(%{body_params: body} = conn) do
    file =
      @sample_file
      |> Map.put("name", Map.get(body, "title", "remote"))
      |> Map.put("file_name", Map.get(body, "title", "remote"))
      |> Map.put("remote_location", Map.get(body, "remote_location"))
      |> Map.put("file_type", Map.get(body, "file_type"))
      |> Map.put("deal_id", parse_int(Map.get(body, "item_id")))

    json(conn, 200, %{"success" => true, "data" => file})
  end

  def handle_remote_link_file(%{body_params: body} = conn) do
    file =
      @sample_file
      |> Map.put("remote_id", Map.get(body, "remote_id"))
      |> Map.put("remote_location", Map.get(body, "remote_location"))
      |> Map.put("deal_id", parse_int(Map.get(body, "item_id")))

    json(conn, 200, %{"success" => true, "data" => file})
  end

  defp file_meta(%{"file" => %Plug.Upload{filename: name, path: path}}) do
    size =
      case Elixir.File.stat(path) do
        {:ok, %{size: size}} -> size
        _ -> 0
      end

    {name || "upload.bin", size}
  end

  defp file_meta(%{"file" => content}) when is_binary(content) do
    {"upload.bin", byte_size(content)}
  end

  defp file_meta(_), do: {"upload.bin", 0}

  defp put_link(file, params, key) do
    case Map.get(params, key) do
      nil -> file
      "" -> file
      value -> Map.put(file, key, parse_int(value) || value)
    end
  end

  defp parse_int(nil), do: nil

  defp parse_int(value) when is_integer(value), do: value

  defp parse_int(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> nil
    end
  end

  defp json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json;charset=utf-8")
    |> send_resp(status, Jason.encode!(body))
  end
end
