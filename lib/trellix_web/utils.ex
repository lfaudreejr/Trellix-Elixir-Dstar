defmodule TrellixWeb.Utils do
  alias Trellix.Users
  alias Trellix.Boards
  alias Trellix.Columns

  def render_component(component) do
    component
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  def get_session_user(conn) do
    session_id = Plug.Conn.get_session(conn, :client_id)

    case Users.get_user_by_session_id(session_id) do
      nil ->
        {:error, :not_found}

      user ->
        {:ok, user}
    end
  end

  def authorize_board_access(conn, board_id) do
    case get_session_user(conn) do
      {:error, :not_found} ->
        {:error, :unauthorized}

      {:ok, user} ->
        case Boards.get_user_board(board_id, user.id) do
          nil -> {:error, :not_found}
          board -> {:ok, user, board}
        end
    end
  end

  def authorize_column_access(conn, column_id) do
    case get_session_user(conn) do
      {:error, :not_found} ->
        {:error, :unauthorized}

      {:ok, user} ->
        case Columns.get_user_column(column_id, user.id) do
          nil -> {:error, :not_found}
          column -> {:ok, user, column}
        end
    end
  end
end
