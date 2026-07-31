defmodule ExPipedrive.FilesTest do
  @moduledoc false
  use ExPipedrive.PipedriveClientCase, async: false

  alias ExPipedrive.Error
  alias ExPipedrive.File
  alias ExPipedrive.Files
  alias ExPipedrive.PagedResult

  describe "list/2" do
    test "lists API v1 files", %{client: client} do
      assert {:ok, %PagedResult{data: [%File{id: 1, file_name: "note.txt", deal_id: 1}]}} =
               Files.list(client)
    end

    test "scopes files by deal_id", %{client: client} do
      assert {:ok, %PagedResult{data: []}} = Files.list(client, deal_id: 999)
    end
  end

  describe "get/2" do
    test "fetches file metadata", %{client: client} do
      assert {:ok, %File{id: 1, name: "note.txt", deal_id: 1}} = Files.get(client, 1)
    end

    test "maps missing files to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Files.get(client, 404)
    end
  end

  describe "upload/4 and create/4" do
    test "uploads multipart content linked to a deal", %{client: client} do
      assert {:ok,
              %File{
                file_name: "hello.txt",
                name: "hello.txt",
                deal_id: 42,
                file_size: 5
              }} = Files.upload(client, "hello", "hello.txt", deal_id: 42)
    end

    test "create/4 aliases upload/4", %{client: client} do
      assert {:ok, %File{file_name: "a.bin", person_id: 7}} =
               Files.create(client, <<1, 2, 3>>, "a.bin", person_id: 7)
    end
  end

  describe "download/2" do
    test "returns raw file bytes", %{client: client} do
      assert {:ok, "hello"} = Files.download(client, 1)
    end

    test "maps missing downloads to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Files.download(client, 404)
    end
  end

  describe "update/3" do
    test "updates file name", %{client: client} do
      assert {:ok, %File{id: 1, name: "renamed.txt"}} =
               Files.update(client, 1, %{name: "renamed.txt"})
    end
  end

  describe "delete/2" do
    test "deletes a file", %{client: client} do
      assert {:ok, :ok} = Files.delete(client, 1)
    end

    test "maps missing files to a structured error", %{client: client} do
      assert {:error, %Error{status: 404}} = Files.delete(client, 404)
    end
  end

  describe "create_remote/2 and remote_link/2" do
    test "creates a remote google drive file linked to a deal", %{client: client} do
      assert {:ok, %File{deal_id: 9, remote_location: "googledrive", file_type: "gdoc"}} =
               Files.create_remote(client, %{
                 file_type: "gdoc",
                 title: "Spec",
                 item_type: "deal",
                 item_id: 9,
                 remote_location: "googledrive"
               })
    end

    test "links an existing remote file", %{client: client} do
      assert {:ok, %File{deal_id: 3, remote_id: "remote-1", remote_location: "googledrive"}} =
               Files.remote_link(client, %{
                 item_type: "deal",
                 item_id: 3,
                 remote_id: "remote-1",
                 remote_location: "googledrive"
               })
    end
  end
end
