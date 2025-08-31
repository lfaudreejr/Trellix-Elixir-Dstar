defmodule TrellixWeb.SSEController do
  require Logger
  use TrellixWeb, :controller

  def sse_req(conn, _params) do
    client_id = get_session(conn, :client_id)
    topic = "client:" <> client_id

    Phoenix.PubSub.subscribe(Trellix.PubSub, topic)

    conn
    |> DataStarSSE.ServerSentEventGenerator.new_sse()
    |> sse_loop()
  end

  defp sse_loop(conn) do
    receive do
      {:patch_elements, payload} ->
        DataStarSSE.ServerSentEventGenerator.patch_elements(conn, payload.html, payload.opts)
        |> sse_loop()

      _ ->
        Logger.log(:info, "sse_loop no match - looping")
        sse_loop(conn)
    after
      15_000 ->
        # Send a periodic ping if no messages in 30s
        case chunk(conn, ": ping\n\n") do
          {:ok, conn} -> sse_loop(conn)
          {:error, :closed} ->
            Logger.log(:info, "sse_loop :closed")
            Plug.Conn.halt(conn)
          {:error, :enotconn} ->
            Logger.log(:info, "sse_loop :enotconn")
            Plug.Conn.halt(conn)
        end
    end
  end
end
