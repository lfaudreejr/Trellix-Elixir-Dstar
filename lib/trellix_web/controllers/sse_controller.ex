defmodule TrellixWeb.SSEController do
  require Logger
  use TrellixWeb, :controller

  def sse_req(conn, _params) do
    session_id = get_session(conn, :client_id)
    topic = "client:" <> session_id

    case Registry.lookup(Trellix.Registry, session_id) do
      [{_pid, connectedConn}] ->
        Logger.info("SSE Already established..halting and unregistering")
        Plug.Conn.halt(connectedConn)
        Registry.unregister(Trellix.Registry, session_id)

      [] ->
        Logger.info("No SSE connection found for current session")
    end

    Phoenix.PubSub.subscribe(Trellix.PubSub, topic)

    Registry.register(Trellix.Registry, session_id, conn)

    conn
    |> DataStarSSE.ServerSentEventGenerator.new_sse()
    |> sse_loop(session_id)
  end

  defp sse_loop(conn, session_id) do
    Logger.info("SSE_REQ State #{conn.state}")

    receive do
      {:patch_elements, payload} ->
        DataStarSSE.ServerSentEventGenerator.patch_elements(conn, payload.html, payload.opts)
        |> sse_loop(session_id)

      _ ->
        Logger.log(:info, "sse_loop no match - looping")
        sse_loop(conn, session_id)
    after
      15_000 ->
        # Send a periodic ping if no messages in 30s
        case chunk(conn, ": ping\n\n") do
          {:ok, conn} ->
            sse_loop(conn, session_id)

          {:error, :closed} ->
            Logger.log(:info, "sse_loop :closed")
            Registry.unregister(Trellix.Registry, session_id)
            Plug.Conn.halt(conn)

          {:error, :enotconn} ->
            Logger.log(:info, "sse_loop :enotconn")
            Registry.unregister(Trellix.Registry, session_id)
            Plug.Conn.halt(conn)
        end
    end
  end
end
