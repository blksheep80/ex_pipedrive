defmodule ExPipedrive.DealParticipants do
  @moduledoc """
  API v1 shim for Pipedrive deal participants.

  Deal participants have no `/api/v2` equivalent yet; all functions here
  explicitly route to `/api/v1/deals/:id/participants`.

  ## Example

      {:ok, %PagedResult{data: participants}} = ExPipedrive.DealParticipants.list(client, deal_id)
      {:ok, participant} = ExPipedrive.DealParticipants.add(client, deal_id, person_id)
      {:ok, :ok} = ExPipedrive.DealParticipants.delete(client, deal_id, participant.id)
  """

  alias ExPipedrive.DealParticipant
  alias ExPipedrive.Error
  alias ExPipedrive.PagedResult
  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias Tesla.Client

  @doc """
  Lists participants via `GET /api/v1/deals/:id/participants`.

  Options: `:start` (default `0`), `:limit`.
  """
  @spec list(Client.t(), term(), keyword()) ::
          {:ok, PagedResult.t()} | {:error, Error.t()}
  def list(%Client{} = client, deal_id, opts \\ []) do
    start = Keyword.get(opts, :start, 0)
    query = [start: start] |> maybe_put(:limit, Keyword.get(opts, :limit))

    client
    |> Request.get("deals/:id/participants",
      api_version: :v1,
      query: query,
      opts: [path_params: [id: deal_id]]
    )
    |> Response.map([200], fn
      %{body: %{"success" => true, "data" => nil} = body} ->
        PagedResult.new([], body)

      %{body: %{"success" => true, "data" => data} = body} ->
        PagedResult.new(Enum.map(data, &DealParticipant.new/1), body)
    end)
  end

  @doc """
  Adds a participant via `POST /api/v1/deals/:id/participants`.
  """
  @spec add(Client.t(), term(), pos_integer()) ::
          {:ok, DealParticipant.t()} | {:error, Error.t()}
  def add(%Client{} = client, deal_id, person_id) do
    client
    |> Request.post("deals/:id/participants", %{"person_id" => person_id},
      api_version: :v1,
      opts: [path_params: [id: deal_id]]
    )
    |> Response.map([200, 201], fn %{body: %{"data" => data}} -> DealParticipant.new(data) end)
  end

  @doc """
  Removes a participant via `DELETE /api/v1/deals/:id/participants/:deal_participant_id`.

  Returns `{:ok, :ok}`.
  """
  @spec delete(Client.t(), term(), term()) :: {:ok, :ok} | {:error, Error.t()}
  def delete(%Client{} = client, deal_id, deal_participant_id) do
    client
    |> Request.delete("deals/:id/participants/:deal_participant_id",
      api_version: :v1,
      opts: [path_params: [id: deal_id, deal_participant_id: deal_participant_id]]
    )
    |> Response.map([200], fn _env -> :ok end)
  end

  defp maybe_put(query, _key, nil), do: query
  defp maybe_put(query, key, value), do: Keyword.put(query, key, value)
end
