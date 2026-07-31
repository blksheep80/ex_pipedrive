defmodule ExPipedrive.Mailbox do
  @moduledoc """
  API v1 client for the Pipedrive Mailbox (mail threads and messages).

  Mailbox is Pipedrive's email hub: mail is synced into threads either via a
  2-way Mail Connection (Gmail/Outlook/IMAP-SMTP) or 1-way via SmartBCC. There
  is no `/api/v2` equivalent yet, so every function here explicitly routes to
  `api_version: :v1`.

  ## Auth / scopes

  Requires the `mail:read` OAuth scope for all read endpoints (`list_threads/2`,
  `get_thread/2`, `list_thread_messages/2`, `get_message/3`). `update_thread/3`
  and `delete_thread/2` additionally require `mail:full`. API-token clients
  need Mailbox access enabled on the authorizing user's Pipedrive account
  (2-way Mail Connection or SmartBCC) — without it these endpoints return
  empty results rather than an error.

  ## Example

      {:ok, threads} = ExPipedrive.Mailbox.list_threads(client, folder: "inbox")
      {:ok, thread} = ExPipedrive.Mailbox.get_thread(client, thread.id)
      {:ok, messages} = ExPipedrive.Mailbox.list_thread_messages(client, thread.id)
      {:ok, message} = ExPipedrive.Mailbox.get_message(client, message.id, include_body: 1)
      {:ok, thread} = ExPipedrive.Mailbox.update_thread(client, thread.id, %{deal_id: deal.id})
      {:ok, :ok} = ExPipedrive.Mailbox.delete_thread(client, thread.id)
  """

  alias ExPipedrive.MailMessage
  alias ExPipedrive.MailThread
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(deal_id lead_id shared_flag read_flag archived_flag)

  @doc """
  Lists mail threads in a folder via `GET /api/v1/mailbox/mailThreads`,
  ordered by the most recent message within each thread.

  Options: `:folder` — one of `"inbox"` (default), `"drafts"`, `"sent"`,
  `"archive"`; `:start` (pagination offset, default `0`); `:limit` (items per
  page).

  Returns `{:ok, [%MailThread{}]}`.
  """
  @spec list_threads(Client.t(), keyword()) ::
          {:ok, [MailThread.t()]} | {:error, ExPipedrive.Error.t()}
  def list_threads(%Client{} = client, opts \\ []) do
    folder = Keyword.get(opts, :folder, "inbox")
    start = Keyword.get(opts, :start, 0)

    query =
      [folder: folder, start: start]
      |> maybe_add(opts, :limit)

    client
    |> Request.get("mailbox/mailThreads", api_version: :v1, query: query)
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      Enum.map(data || [], &MailThread.new/1)
    end)
  end

  @doc """
  Fetches a mail thread by id via `GET /api/v1/mailbox/mailThreads/:id`.

  Returns `{:ok, %MailThread{}}`.
  """
  @spec get_thread(Client.t(), pos_integer()) ::
          {:ok, MailThread.t()} | {:error, ExPipedrive.Error.t()}
  def get_thread(%Client{} = client, thread_id) do
    client
    |> Request.get("mailbox/mailThreads/:id",
      api_version: :v1,
      opts: [path_params: [id: thread_id]]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      MailThread.new(data)
    end)
  end

  @doc """
  Lists all mail messages inside a thread via
  `GET /api/v1/mailbox/mailThreads/:id/mailMessages`.

  Returns `{:ok, [%MailMessage{}]}`.
  """
  @spec list_thread_messages(Client.t(), pos_integer()) ::
          {:ok, [MailMessage.t()]} | {:error, ExPipedrive.Error.t()}
  def list_thread_messages(%Client{} = client, thread_id) do
    client
    |> Request.get("mailbox/mailThreads/:id/mailMessages",
      api_version: :v1,
      opts: [path_params: [id: thread_id]]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      Enum.map(data || [], &MailMessage.new/1)
    end)
  end

  @doc """
  Fetches a single mail message via
  `GET /api/v1/mailbox/mailMessages/:id`.

  Options: `:include_body` — `0` (default, omit body) or `1` (include the
  full message body).

  Returns `{:ok, %MailMessage{}}`.
  """
  @spec get_message(Client.t(), pos_integer(), keyword()) ::
          {:ok, MailMessage.t()} | {:error, ExPipedrive.Error.t()}
  def get_message(%Client{} = client, message_id, opts \\ []) do
    include_body = Keyword.get(opts, :include_body, 0)

    client
    |> Request.get("mailbox/mailMessages/:id",
      api_version: :v1,
      query: [include_body: include_body],
      opts: [path_params: [id: message_id]]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      MailMessage.new(data)
    end)
  end

  @doc """
  Updates a mail thread's associations/flags via
  `PUT /api/v1/mailbox/mailThreads/:id`.

  Accepts a map with any of `:deal_id`, `:lead_id`, `:shared_flag`,
  `:read_flag`, `:archived_flag`. Requires the `mail:full` scope.

  Returns `{:ok, %MailThread{}}`.
  """
  @spec update_thread(Client.t(), pos_integer(), map()) ::
          {:ok, MailThread.t()} | {:error, ExPipedrive.Error.t()}
  def update_thread(%Client{} = client, thread_id, attrs) when is_map(attrs) do
    client
    |> Request.put(
      "mailbox/mailThreads/:id",
      WriteAttrs.take(attrs, @write_fields),
      api_version: :v1,
      opts: [path_params: [id: thread_id]]
    )
    |> Response.map([200], fn %{body: %{"success" => true, "data" => data}} ->
      MailThread.new(data)
    end)
  end

  @doc """
  Marks a mail thread as deleted via
  `DELETE /api/v1/mailbox/mailThreads/:id`. Requires the `mail:full` scope.

  Returns `{:ok, :ok}`.
  """
  @spec delete_thread(Client.t(), pos_integer()) :: {:ok, :ok} | {:error, ExPipedrive.Error.t()}
  def delete_thread(%Client{} = client, thread_id) do
    client
    |> Request.delete("mailbox/mailThreads/:id",
      api_version: :v1,
      opts: [path_params: [id: thread_id]]
    )
    |> Response.map([200], fn _env -> :ok end)
  end

  defp maybe_add(query, opts, key) do
    case Keyword.get(opts, key) do
      nil -> query
      value -> Keyword.put(query, key, value)
    end
  end
end
