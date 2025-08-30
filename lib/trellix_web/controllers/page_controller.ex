defmodule TrellixWeb.PageController do
  use TrellixWeb, :controller
  alias Trellix.Users
  alias TrellixWeb

  def home(conn, _params) do
    client_id = get_session(conn, :client_id)
    csrf_token = get_csrf_token()

    user =
      case Users.get_user_by_session_id(client_id) do
        nil ->
          Users.create_user(%{session_id: client_id})

        user ->
          user
      end

    render(conn, :home, user: user, csrf_token: csrf_token)
  end

  def sse(conn, _params) do
    client_id = get_session(conn, :client_id)
    topic = "client:" <> client_id

    Phoenix.PubSub.subscribe(Trellix.PubSub, topic)

    conn
    |> DataStarSSE.ServerSentEventGenerator.new_sse()
    |> listen_for_datastar_events()
  end

  defp listen_for_datastar_events(conn) do
    receive do
      {:patch_elements, payload} ->
        DataStarSSE.ServerSentEventGenerator.patch_elements(conn, payload.html, payload.opts)
        |> listen_for_datastar_events()

      {:patch_signals, payload} ->
        DataStarSSE.ServerSentEventGenerator.patch_signals(conn, payload.signals, payload.opts)
        |> listen_for_datastar_events()

      _ ->
        listen_for_datastar_events(conn)
    after
      5_000 ->
        # Send a periodic ping if no messages in 30s
        case chunk(conn, ": ping\n\n") do
          {:ok, conn} -> listen_for_datastar_events(conn)
          {:error, :closed} -> Plug.Conn.halt(conn)
          {:error, :enotconn} -> Plug.Conn.halt(conn)
        end
    end
  end
end
