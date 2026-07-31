defmodule ExPipedrive.ActivityTypes do
  @moduledoc """
  API v1 client for Pipedrive activity types.

  Activity types remain on `/api/v1/activityTypes`; there is no `/api/v2`
  equivalent and no single-type get endpoint. Use `list/1` and `get/2`
  (client-side lookup) for reads; `create/2`, `update/3`, and `delete/2`
  for admin writes (`admin` OAuth scope).

  ## Example

      {:ok, types} = ExPipedrive.ActivityTypes.list(client)
      {:ok, type} = ExPipedrive.ActivityTypes.get(client, 1)

      {:ok, custom} =
        ExPipedrive.ActivityTypes.create(client, %{
          name: "Video call",
          icon_key: "camera",
          color: "aeb31b"
        })

      {:ok, custom} =
        ExPipedrive.ActivityTypes.update(client, custom.id, %{order_nr: 10})

      {:ok, :ok} = ExPipedrive.ActivityTypes.delete(client, custom.id)
  """

  alias ExPipedrive.ActivityType
  alias ExPipedrive.Error
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(name icon_key color order_nr)

  @doc """
  Lists activity types via `GET /api/v1/activityTypes`.

  Returns `{:ok, [%ActivityType{}]}`.
  """
  @spec list(Client.t()) :: {:ok, [ActivityType.t()]} | {:error, Error.t()}
  def list(%Client{} = client) do
    client
    |> Request.get("activityTypes", api_version: :v1)
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil}} ->
        []

      %{body: %{"success" => true, "data" => data}} when is_list(data) ->
        Enum.map(data, &ActivityType.new/1)
    end)
  end

  @doc """
  Alias for `list/1`.
  """
  @spec list_activity_types(Client.t()) :: {:ok, [ActivityType.t()]} | {:error, Error.t()}
  defdelegate list_activity_types(client), to: __MODULE__, as: :list

  @doc """
  Fetches an activity type by id (client-side over `list/1`).

  Pipedrive has no `GET /activityTypes/:id`. Returns `{:ok, %ActivityType{}}`
  or `{:error, %Error{kind: :not_found}}`.
  """
  @spec get(Client.t(), pos_integer()) :: {:ok, ActivityType.t()} | {:error, Error.t()}
  def get(%Client{} = client, id) when is_integer(id) do
    with {:ok, types} <- list(client) do
      case Enum.find(types, &(&1.id == id)) do
        nil -> {:error, not_found("Activity type #{id} not found")}
        type -> {:ok, type}
      end
    end
  end

  @doc """
  Creates an activity type via `POST /api/v1/activityTypes`.

  Requires `:name` and `:icon_key`. Optional `:color` (6-char HEX without `#`)
  and `:order_nr`.

  Returns `{:ok, %ActivityType{}}`.
  """
  @spec create(Client.t(), map()) :: {:ok, ActivityType.t()} | {:error, Error.t()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    client
    |> Request.post("activityTypes", WriteAttrs.take(attrs, @write_fields), api_version: :v1)
    |> Response.map([200, 201], fn %{body: %{"data" => data}} -> ActivityType.new(data) end)
  end

  @doc """
  Updates an activity type via `PUT /api/v1/activityTypes/:id`.

  Accepted attrs: `:name`, `:icon_key`, `:color`, `:order_nr`.

  Returns `{:ok, %ActivityType{}}`.
  """
  @spec update(Client.t(), pos_integer(), map()) ::
          {:ok, ActivityType.t()} | {:error, Error.t()}
  def update(%Client{} = client, id, attrs) when is_integer(id) and is_map(attrs) do
    client
    |> Request.put("activityTypes/:id", WriteAttrs.take(attrs, @write_fields),
      api_version: :v1,
      opts: [path_params: [id: id]]
    )
    |> Response.map([200], fn %{body: %{"data" => data}} -> ActivityType.new(data) end)
  end

  @doc """
  Deletes (soft-deletes) an activity type via `DELETE /api/v1/activityTypes/:id`.

  Returns `{:ok, :ok}`.
  """
  @spec delete(Client.t(), pos_integer()) :: {:ok, :ok} | {:error, Error.t()}
  def delete(%Client{} = client, id) when is_integer(id) do
    client
    |> Request.delete("activityTypes/:id", api_version: :v1, opts: [path_params: [id: id]])
    |> Response.map([200], fn _env -> :ok end)
  end

  defp not_found(message) do
    %Error{
      kind: :not_found,
      message: message,
      status: 404,
      body: nil,
      headers: [],
      request_id: nil,
      rate_limit: nil,
      reason: nil
    }
  end
end
