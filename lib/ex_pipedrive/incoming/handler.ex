if Code.ensure_loaded?(Plug.Router) do
  defmodule ExPipedrive.Incoming.Handler do
    @moduledoc """
    Plug router for incoming Pipedrive webhook POSTs.

    Transforms known events into `{event_type, payload}` tuples and delivers them
    to an optional `on_event/1` callback supplied at mount time. The host
    application owns fan-out (Registry, PubSub, etc.) — core does not start any
    OTP processes for webhooks.

    Requires the optional `plug` dependency. Add to your app:

        {:plug, ">= 1.16.0"}

    Without `plug`, this module is not compiled. Payload transformers
    (`ExPipedrive.Incoming.DealHandler` / `PersonHandler`) remain available
    without Plug. A dedicated `ex_pipedrive_web` package may replace this later.

    ## Example

        on_event = fn {:updated_deal, payload} ->
          MyApp.Deals.handle_update(payload)
        end

        forward "/webhooks", to: ExPipedrive.Incoming.Handler,
          init_opts: [auth_fn: &my_basic_auth/0, on_event: on_event]

    See https://pipedrive.readme.io/docs/guide-for-webhooks for event types and
    payload shapes.
    """

    use ExPipedrive.Incoming.DealHandler
    use ExPipedrive.Incoming.PersonHandler
    use Plug.Router

    require Logger

    plug(Plug.Parsers,
      parsers: [:json],
      json_decoder: Jason
    )

    plug(:match)
    plug(:dispatch)

    def init(opts) do
      unless Keyword.has_key?(opts, :auth_fn) do
        raise ArgumentError, "ExPipedrive.Incoming.Handler requires :auth_fn in init opts"
      end

      opts
    end

    def call(conn, opts) do
      auth_fn = Keyword.fetch!(opts, :auth_fn)
      auth_opts = if is_function(auth_fn), do: auth_fn.(), else: opts

      conn =
        conn
        |> Plug.BasicAuth.basic_auth(auth_opts)
        |> put_private(:ex_pipedrive_handler_opts, opts)

      super(conn, opts)
    end

    post "/webhook" do
      opts = conn.private[:ex_pipedrive_handler_opts]

      conn.body_params
      |> process_event()
      |> deliver_event(Keyword.get(opts, :on_event))

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

    def transform_event(_, payload) do
      Logger.warning("Unhandled incoming event: #{inspect(payload)}")

      nil
    end

    @doc """
    Delivers a transformed webhook event to `on_event/1` when configured.

    Returns `:ok`. With no callback, known events are dropped after a debug log.
    """
    def deliver_event(nil, _on_event), do: :ok

    def deliver_event(event, on_event) when is_function(on_event, 1) do
      on_event.(event)
      :ok
    end

    def deliver_event({event_type, _message}, nil) do
      Logger.debug(
        "Webhook event #{inspect(event_type)} received (no :on_event callback configured)"
      )

      :ok
    end
  end
end
