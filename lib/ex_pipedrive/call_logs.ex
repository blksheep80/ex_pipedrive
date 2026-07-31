defmodule ExPipedrive.CallLogs do
  @moduledoc """
  API v1 client for Pipedrive call logs.

  Call logs describe the outcome of a phone call managed by an integrated
  provider. They remain on `/api/v1/callLogs`; there is no `/api/v2`
  equivalent yet, so every function here explicitly routes to
  `api_version: :v1`.

  Pipedrive's call log API does not expose an update endpoint — only
  `list/2`, `get/2`, `create/2`, `delete/2`, and `add_recording/3` (attach an
  audio file) are supported.

  Unlike most Pipedrive entities, call log ids are Pipedrive-generated hex
  strings (e.g. `"CAd92b224eb4a39b5ad8fea92ff0e"`), not integers.

  ## Example

      {:ok, call_log} =
        ExPipedrive.CallLogs.create(client, %{
          to_phone_number: "+37249234343",
          outcome: "connected",
          start_time: "2022-12-12 01:01:01",
          end_time: "2022-12-12 01:02:01"
        })

      {:ok, page} = ExPipedrive.CallLogs.list(client)
      {:ok, call_log} = ExPipedrive.CallLogs.get(client, call_log.id)
      {:ok, :ok} = ExPipedrive.CallLogs.add_recording(client, call_log.id, wav_bytes, "call.wav")
      {:ok, :ok} = ExPipedrive.CallLogs.delete(client, call_log.id)
  """

  alias ExPipedrive.CallLog
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client
  alias Tesla.Multipart

  @write_fields ~w(
    user_id activity_id subject duration outcome from_phone_number
    to_phone_number start_time end_time person_id org_id deal_id lead_id note
  )

  @doc """
  Lists call logs assigned to the authenticated user via
  `GET /api/v1/callLogs`.

  Options: `:start` (default `0`), `:limit` (max `50`).

  Returns `{:ok, %PagedResult{}}`.
  """
  @spec list(Client.t(), keyword()) :: {:ok, PagedResult.t()} | {:error, ExPipedrive.Error.t()}
  def list(%Client{} = client, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    limit = Keyword.get(opts, :limit, 50)

    client
    |> Request.get("callLogs", api_version: :v1, query: [start: start, limit: limit])
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} ->
        PagedResult.new(Enum.map(data, &CallLog.new/1), body)
    end)
  end

  @doc """
  Fetches a call log by id via `GET /api/v1/callLogs/:id`.

  Returns `{:ok, %CallLog{}}`.
  """
  @spec get(Client.t(), String.t()) :: {:ok, CallLog.t()} | {:error, ExPipedrive.Error.t()}
  def get(%Client{} = client, call_log_id) do
    client
    |> Request.get("callLogs/:id", api_version: :v1, opts: [path_params: [id: call_log_id]])
    |> Response.map([200], fn %{body: %{"data" => data}} -> CallLog.new(data) end)
  end

  @doc """
  Creates a call log via `POST /api/v1/callLogs`.

  Requires `:to_phone_number`, `:outcome` (one of `"connected"`,
  `"no_answer"`, `"left_message"`, `"left_voicemail"`, `"wrong_number"`,
  `"busy"`), `:start_time`, and `:end_time`. When `:activity_id` is given,
  that activity is converted into the call log and `:deal_id`, `:person_id`,
  `:org_id` are ignored in favor of the activity's own associations.

  Returns `{:ok, %CallLog{}}`.
  """
  @spec create(Client.t(), map()) :: {:ok, CallLog.t()} | {:error, ExPipedrive.Error.t()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    client
    |> Request.post("callLogs", WriteAttrs.take(attrs, @write_fields), api_version: :v1)
    |> Response.map([200, 201], fn %{body: %{"data" => data}} -> CallLog.new(data) end)
  end

  @doc """
  Attaches an audio recording to a call log via
  `POST /api/v1/callLogs/:id/recordings` (`multipart/form-data`).

  `content` is the audio file body; `filename` is sent as the multipart
  filename. Returns `{:ok, :ok}`.
  """
  @spec add_recording(Client.t(), String.t(), iodata(), String.t()) ::
          {:ok, :ok} | {:error, ExPipedrive.Error.t()}
  def add_recording(%Client{} = client, call_log_id, content, filename)
      when (is_binary(content) or is_list(content)) and is_binary(filename) do
    multipart =
      Multipart.new()
      |> Multipart.add_file_content(IO.iodata_to_binary(content), filename, name: "file")

    client
    |> Request.post(
      "callLogs/:id/recordings",
      multipart,
      api_version: :v1,
      opts: [path_params: [id: call_log_id]]
    )
    |> Response.map([200, 201], fn _env -> :ok end)
  end

  @doc """
  Deletes a call log via `DELETE /api/v1/callLogs/:id`.

  If an audio recording is attached, it is deleted along with the call log.
  The related activity, if any, is left untouched. Returns `{:ok, :ok}`.
  """
  @spec delete(Client.t(), String.t()) :: {:ok, :ok} | {:error, ExPipedrive.Error.t()}
  def delete(%Client{} = client, call_log_id) do
    client
    |> Request.delete("callLogs/:id", api_version: :v1, opts: [path_params: [id: call_log_id]])
    |> Response.map([200], fn _env -> :ok end)
  end
end
