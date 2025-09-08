defmodule TrellixWeb.BoardController do
  use TrellixWeb, :controller

  require Logger
  alias Trellix.Users
  alias Trellix.Boards
  alias Trellix.Columns
  alias TrellixWeb.Utils
  alias TrellixWeb.BoardComponents

  def get(conn, %{"id" => id}) do
    csrf_token = get_csrf_token()

    case Utils.authorize_board_access(conn, id) do
      {:error, _} ->
        Logger.info("GET Board - No board access")
        resp(conn, 404, "Not Found")

      {:ok, user, board} ->
        render(conn, :board, user: user, board: board, csrf_token: csrf_token)
    end
  end

  def create(conn, %{"name" => name, "color" => color}) do
    csrf_token = get_csrf_token()
    session_id = get_session(conn, :client_id)
    topic = "client:" <> session_id

    case Users.get_user_by_session_id(session_id) do
      nil ->
        Logger.log(:info, "Create Board - Session User Not Found")

      user ->
        case Boards.create_board(%{
               name: name,
               color: color,
               user_id: user.id
             }) do
          {:ok, board} ->
            html =
              Utils.render_component(
                BoardComponents.board_card(%{board: board, csrf_token: csrf_token})
              )

            payload = %{html: html, opts: [mode: "append", selector: "#boards-container"]}

            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})

          {:error, _} ->
            Logger.log(:info, "Could not create board")
        end
    end

    resp(conn, 200, "OK")
  end

  def delete(conn, %{"id" => id}) do
    case Utils.authorize_board_access(conn, id) do
      {:error, _} ->
        Logger.info("Authorize Board Access Error")

      {:ok, user, board} ->
        case Boards.delete_board(board) do
          {:ok, _} ->
            topic = "client:" <> user.session_id
            payload = %{html: nil, opts: [mode: "remove", selector: "#board-#{id}"]}
            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})

          {:error, _} ->
            Logger.info("Delete Board Failed")
        end
    end

    resp(conn, 200, "OK")
  end

  def change_name(conn, %{"board_id" => board_id, "board_name" => board_name}) do
    case Utils.authorize_board_access(conn, board_id) do
      {:error, _} ->
        Logger.info("Board Name Change - Session Unauthenticated")
        resp(conn, 401, "Unauthorized")

      {:ok, user, board} ->
        csrf_token = get_csrf_token()
        topic = "client:" <> user.session_id

        case Boards.update_board(board, %{name: board_name}) do
          {:error, _} ->
            Logger.info("Board Change Name - Error Updating Board")
            resp(conn, 500, "Server Error")

          {:ok, board} ->
            html =
              Utils.render_component(
                BoardComponents.board_name_input(%{board: board, csrf_token: csrf_token})
              )

            payload = %{
              html: html,
              opts: [mode: "replace", selector: "#board-#{board.id}-name"]
            }

            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})

            resp(conn, 200, "OK")
        end
    end
  end

  def create_column(conn, %{"new-column-name" => column_name, "board_id" => board_id}) do
    csrf_token = get_csrf_token()

    case Utils.authorize_board_access(conn, board_id) do
      {:error, _} ->
        Logger.info("Column Create - Unauthorized Board Access")
        resp(conn, 401, "Unauthorized")

      {:ok, user, board} ->
        position = Enum.count(board.columns) + 1

        case Columns.create_column(%{
               name: column_name,
               board_id: board.id,
               position: position,
               user_id: user.id
             }) do
          {:error, _} ->
            Logger.info("Column Create - Failed")
            resp(conn, 500, "Server Error")

          {:ok, _} ->
            case Boards.get_user_board(board.id, user.id) do
              nil ->
                Logger.info("Create Column - Get User Board Failed")
                resp(conn, 500, "Server Error")

              board ->
                render(conn, :board, board: board, csrf_token: csrf_token)
            end
        end
    end
  end
end
