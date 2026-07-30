defmodule ExPipedrive.Webhooks do
  @moduledoc """
  Manages outgoing Pipedrive webhook subscriptions through API v1.

  Pipedrive's webhook-management endpoints remain under `/api/v1/webhooks`;
  the webhook **delivery** format defaults to v2.0 when `:version` is omitted.
  This module manages subscriptions, while `ExPipedrive.Webhook.*` and
  `ExPipedrive.Incoming.*` handle webhook payloads received by your app.

  ## Authorization

  OAuth applications need `webhooks:read` to list subscriptions and
  `webhooks:full` to create or delete them. API tokens use the permissions of
  their owning user. Regular users can manage only their own subscriptions and
  events visible to that user; use a top-level admin user's token or `user_id`
  when a subscription must cover all company events.

  ## Example

      {:ok, subscription} =
        ExPipedrive.Webhooks.create(client, %{
          subscription_url: "https://example.com/pipedrive/webhooks",
          event_action: "change",
          event_object: "deal",
          name: "Deal changes"
        })

      {:ok, subscriptions} = ExPipedrive.Webhooks.list(client)
      {:ok, :ok} = ExPipedrive.Webhooks.delete(client, subscription.id)
  """

  alias ExPipedrive.Request
  alias ExPipedrive.Response
  alias ExPipedrive.Webhooks.Subscription
  alias ExPipedrive.WriteAttrs
  alias Tesla.Client

  @write_fields ~w(
    subscription_url event_action event_object name user_id http_auth_user
    http_auth_password version
  )

  @doc """
  Lists the webhook subscriptions visible to the authenticated user via
  `GET /api/v1/webhooks`.

  Returns `{:ok, [%Subscription{}]}`.
  """
  @spec list(Client.t()) :: {:ok, [Subscription.t()]} | {:error, ExPipedrive.Error.t()}
  def list(%Client{} = client) do
    client
    |> Request.get("webhooks", api_version: :v1)
    |> Response.map([200], fn %{body: %{"data" => data}} ->
      Enum.map(data || [], &Subscription.new/1)
    end)
  end

  @doc """
  Creates an outgoing webhook subscription via `POST /api/v1/webhooks`.

  `:subscription_url`, `:event_action`, and `:event_object` are required by
  Pipedrive. `:version` accepts `"1.0"` or `"2.0"`; Pipedrive defaults it to
  `"2.0"` when omitted.

  Returns `{:ok, %Subscription{}}`.
  """
  @spec create(Client.t(), map()) :: {:ok, Subscription.t()} | {:error, ExPipedrive.Error.t()}
  def create(%Client{} = client, attrs) when is_map(attrs) do
    client
    |> Request.post("webhooks", WriteAttrs.take(attrs, @write_fields), api_version: :v1)
    |> Response.map([201], fn %{body: %{"data" => subscription}} ->
      Subscription.new(subscription)
    end)
  end

  @doc """
  Deletes an outgoing webhook subscription via `DELETE /api/v1/webhooks/:id`.

  Returns `{:ok, :ok}`.
  """
  @spec delete(Client.t(), pos_integer()) :: {:ok, :ok} | {:error, ExPipedrive.Error.t()}
  def delete(%Client{} = client, subscription_id) do
    client
    |> Request.delete("webhooks/:id",
      api_version: :v1,
      opts: [path_params: [id: subscription_id]]
    )
    |> Response.map([200], fn _env -> :ok end)
  end
end
