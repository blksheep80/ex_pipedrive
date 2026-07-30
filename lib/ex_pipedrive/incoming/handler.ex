if Code.ensure_loaded?(Plug.Router) do
  defmodule ExPipedrive.Incoming.Handler do
    @moduledoc """
    Plug router for incoming Pipedrive webhook POSTs.

    Normalizes Pipedrive payloads into `ExPipedrive.Webhook.Event` structs and
    delivers them to an optional `ExPipedrive.Webhook.Handler` module. The host
    application owns fan-out (Registry, PubSub, etc.) — core does not start any
    OTP processes for webhooks.

    Requires the optional `plug` dependency. Add to your app:

        {:plug, ">= 1.16.0"}

    Without `plug`, this module is not compiled. Payload transformers
    (`ExPipedrive.Webhook.Event` and `ExPipedrive.Webhook.Handler`) remain
    available without Plug. This is the in-repository `ex_pipedrive_web`
    surface, reserved for extraction as an optional package.

    ## Example

        forward "/webhooks", to: ExPipedrive.Incoming.Handler,
          init_opts: [handler: MyApp.PipedriveWebhookHandler,
                      auth_fn: fn -> [username: "pipedrive", password: secret] end]

    See https://pipedrive.readme.io/docs/guide-for-webhooks for event types and
    payload shapes. `:auth_fn` is optional; when present it can be a zero-arity
    function returning `Plug.BasicAuth` options or those options directly.

    ## Compatibility

    `on_event: fn {:updated_deal, payload} -> ... end` remains supported for
    deal and person update events. New integrations should configure `:handler`
    and implement `ExPipedrive.Webhook.Handler`.
    """

    use ExPipedrive.Incoming.DealHandler
    use ExPipedrive.Incoming.PersonHandler
    use Plug.Router

    require Logger

    alias ExPipedrive.Webhook.Event

    plug(Plug.Parsers,
      parsers: [:json],
      json_decoder: Jason
    )

    plug(:match)
    plug(:dispatch)

    def init(opts) do
      case Keyword.get(opts, :auth_fn) do
        nil -> opts
        auth_fn when is_function(auth_fn, 0) -> opts
        auth_opts when is_list(auth_opts) -> opts
        _ -> raise ArgumentError, ":auth_fn must be a zero-arity function or basic auth options"
      end
    end

    def call(conn, opts) do
      conn =
        conn
        |> maybe_basic_auth(Keyword.get(opts, :auth_fn))
        |> put_private(:ex_pipedrive_handler_opts, opts)

      super(conn, opts)
    end

    post "/webhook" do
      opts = conn.private[:ex_pipedrive_handler_opts]

      conn.body_params
      |> normalize_event()
      |> deliver_event(opts)

      send_resp(conn, 200, "")
    end

    match _ do
      send_resp(conn, 404, "")
    end

    def process_event(%{"event" => event_type} = payload) do
      transform_event(event_type, payload)
    end

    def process_event(_payload) do
      nil
    end

    @doc "Normalizes a Pipedrive webhook payload into an `Event`."
    @spec normalize_event(map()) :: Event.t() | nil
    def normalize_event(payload) do
      case Event.from_payload(payload) do
        {:ok, event} ->
          event

        {:error, :invalid_payload} ->
          Logger.warning("Invalid incoming webhook payload: #{inspect(payload)}")
          nil
      end
    end

    def transform_event(_, payload) do
      Logger.warning("Unhandled incoming event: #{inspect(payload)}")

      nil
    end

    @doc """
    Delivers a normalized webhook event to the configured handler.

    `:handler` is preferred. `:on_event` receives the historical tuple shape
    for deal/person update events when no handler is configured.
    """
    def deliver_event(nil, _opts), do: :ok

    def deliver_event(event, opts) do
      case Keyword.get(opts, :handler) do
        handler when is_atom(handler) and not is_nil(handler) ->
          handler.handle_event(event)

        nil ->
          deliver_legacy_event(event, Keyword.get(opts, :on_event))
      end

      :ok
    end

    defp maybe_basic_auth(conn, nil), do: conn

    defp maybe_basic_auth(conn, auth_fn) when is_function(auth_fn, 0) do
      Plug.BasicAuth.basic_auth(conn, auth_fn.())
    end

    defp maybe_basic_auth(conn, auth_opts), do: Plug.BasicAuth.basic_auth(conn, auth_opts)

    defp deliver_legacy_event(event, on_event) when is_function(on_event, 1) do
      case process_event(event.raw) do
        nil -> :ok
        legacy_event -> on_event.(legacy_event)
      end
    end

    defp deliver_legacy_event(event, nil) do
      Logger.debug("Webhook event #{inspect(event.name)} received (no handler configured)")

      :ok
    end
  end
end
