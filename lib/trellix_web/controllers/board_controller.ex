defmodule TrellixWeb.BoardController do
  use TrellixWeb, :controller
  require Logger
  alias Trellix.Columns
  alias Trellix.Users
  alias Trellix.Boards
  alias Trellix.Cards
  alias TrellixWeb

  def board(conn, %{"id" => id}) do
    csrf_token = get_csrf_token()

    case authorize_board_access(conn, id) do
      {:ok, _user, board} ->
        render(conn, :board, board: board, csrf_token: csrf_token)

      {:error, :unauthorized} ->
        send_resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        send_resp(conn, 401, "Not Found")
    end
  end

  def board_create(conn, %{"name" => name, "color" => color}) do
    IO.inspect(name, label: "Name")
    IO.inspect(color, label: "Color")
    client_id = get_session(conn, :client_id)
    topic = "client:" <> client_id

    case Users.get_user_by_session_id(client_id) do
      nil ->
        resp(conn, 404, "Not Found")

      user ->
        {:ok, board} =
          Boards.create_board(%{
            name: name,
            color: color,
            user_id: user.id
          })

        csrf_token = get_csrf_token()

        html =
          render_component(
            TrellixWeb.AppComponents.board_card(%{
              color: board.color,
              name: board.name,
              id: board.id,
              csrf_token: csrf_token
            })
          )

        payload = %{html: html, opts: [mode: "append", selector: "#boards-container"]}

        Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
    end

    resp(conn, 200, "OK")
  end

  def board_delete(conn, %{"id" => id}) do
    client_id = get_session(conn, :client_id)
    topic = "client:" <> client_id

    case authorize_board_access(conn, id) do
      {:ok, _user, board} ->
        case Boards.delete_board(board) do
          {:ok, _struct} ->
            payload = %{html: nil, opts: [mode: "remove", selector: "#board-#{id}"]}
            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
            resp(conn, 200, "OK")

          {:error, _changeset} ->
            resp(conn, 500, "Error")
        end

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def edit_board_name_get(conn, %{"id" => id}) do
    client_id = get_session(conn, :client_id)
    topic = "client:" <> client_id
    csrf_token = get_csrf_token()

    case authorize_board_access(conn, id) do
      {:ok, _user, board} ->
        html =
          TrellixWeb.AppComponents.board_name_edit(%{board: board, csrf_token: csrf_token})
          |> render_component()

        payload = %{html: html, opts: [mode: "inner", selector: "#board-name"]}
        Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
        resp(conn, 200, "OK")

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def edit_board_name_cancel(conn, %{"id" => id}) do
    client_id = get_session(conn, :client_id)
    topic = "client:" <> client_id

    case authorize_board_access(conn, id) do
      {:ok, _user, board} ->
        html =
          TrellixWeb.AppComponents.board_name(%{board: board})
          |> render_component()

        payload = %{html: html, opts: [mode: "inner", selector: "#board-name"]}
        Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
        resp(conn, 200, "OK")

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def edit_board_name_submit(conn, %{"id" => id, "boardName" => board_name}) do
    client_id = get_session(conn, :client_id)
    topic = "client:" <> client_id

    IO.inspect(board_name, label: "BOARD NAME INCOMING")

    case authorize_board_access(conn, id) do
      {:ok, _user, board} ->
        case Boards.update_board(board, %{name: board_name}) do
          {:ok, board} ->
            html =
              TrellixWeb.AppComponents.board_name(%{board: board})
              |> render_component()

            payload = %{html: html, opts: [mode: "inner", selector: "#board-name"]}
            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
            resp(conn, 200, "OK")

          {:error, _} ->
            html =
              TrellixWeb.AppComponents.board_name(%{board: board})
              |> render_component()

            payload = %{html: html, opts: [mode: "inner", selector: "#board-name"]}
            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
            resp(conn, 500, "Error")
        end

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def board_column_create_get(conn, %{"id" => id}) do
    case authorize_board_access(conn, id) do
      {:ok, _user, _board} ->
        client_id = get_session(conn, :client_id)
        topic = "client:" <> client_id
        csrf_token = get_csrf_token()

        html =
          TrellixWeb.AppComponents.column_create_form(%{board_id: id, csrf_token: csrf_token})
          |> render_component

        payload = %{html: html, opts: []}
        Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
        resp(conn, 200, "Ok")

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def board_column_create_cancel(conn, %{"id" => id}) do
    case authorize_board_access(conn, id) do
      {:ok, _user, _board} ->
        client_id = get_session(conn, :client_id)
        topic = "client:" <> client_id
        csrf_token = get_csrf_token()

        html =
          TrellixWeb.AppComponents.column_create_button(%{board_id: id, csrf_token: csrf_token})
          |> render_component

        payload = %{html: html, opts: []}
        Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
        resp(conn, 200, "Ok")

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def board_column_create_submit(conn, %{"id" => id, "columnName" => column_name}) do
    csrf_token = get_csrf_token()

    case authorize_board_access(conn, id) do
      {:ok, user, board} ->
        position = Enum.count(board.columns) + 1

        case Columns.create_column(%{
               board_id: board.id,
               name: column_name,
               position: position,
               user_id: user.id
             }) do
          {:ok, _column} ->
            case authorize_board_access(conn, id) do
              {:ok, _user, updated_board} ->
                render(conn, :board, board: updated_board, csrf_token: csrf_token)

              _ ->
                send_resp(conn, 500, "Error")
            end

          {:error, error} ->
            IO.inspect(error, label: "Create Column Error")
            send_resp(conn, 500, "Error")
        end

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def edit_column_name_get(conn, %{"id" => id}) do
    client_id = get_session(conn, :client_id)
    topic = "client:" <> client_id
    csrf_token = get_csrf_token()

    case authorize_column_access(conn, id) do
      {:ok, _user, column} ->
        html =
          TrellixWeb.AppComponents.column_name_edit(%{column: column, csrf_token: csrf_token})
          |> render_component()

        payload = %{html: html, opts: [mode: "inner", selector: "#column-#{column.id}-name"]}
        Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
        resp(conn, 200, "OK")

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def edit_column_name_cancel(conn, %{"id" => id}) do
    client_id = get_session(conn, :client_id)
    topic = "client:" <> client_id

    case authorize_column_access(conn, id) do
      {:ok, _user, column} ->
        html =
          TrellixWeb.AppComponents.column_name(%{column: column})
          |> render_component()

        payload = %{html: html, opts: [mode: "inner", selector: "#column-#{column.id}-name"]}
        Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
        resp(conn, 200, "OK")

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def edit_column_name_submit(conn, %{"id" => id, "columnName" => column_name}) do
    client_id = get_session(conn, :client_id)
    topic = "client:" <> client_id

    IO.inspect(column_name, label: "COLUMN NAME INCOMING")

    case authorize_column_access(conn, id) do
      {:ok, _user, column} ->
        case Columns.update_column(column, %{name: column_name}) do
          {:ok, column} ->
            html =
              TrellixWeb.AppComponents.column_name(%{column: column})
              |> render_component()

            payload = %{html: html, opts: [mode: "inner", selector: "#column-#{column.id}-name"]}
            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
            resp(conn, 200, "OK")

          {:error, _} ->
            html =
              TrellixWeb.AppComponents.column_name(%{column: column})
              |> render_component()

            payload = %{html: html, opts: [mode: "inner", selector: "#column-#{column.id}-name"]}
            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
            resp(conn, 500, "Error")
        end

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def column_card_create_get(conn, %{"id" => id}) do
    case authorize_column_access(conn, id) do
      {:ok, _user, _column} ->
        client_id = get_session(conn, :client_id)
        topic = "client:" <> client_id
        csrf_token = get_csrf_token()

        html =
          TrellixWeb.AppComponents.add_card_form(%{column_id: id, csrf_token: csrf_token})
          |> render_component

        payload = %{html: html, opts: [mode: "inner", selector: "#column-#{id}-actions"]}
        Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
        resp(conn, 200, "Ok")

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def column_card_create_cancel(conn, %{"id" => id}) do
    case authorize_column_access(conn, id) do
      {:ok, _user, _column} ->
        client_id = get_session(conn, :client_id)
        topic = "client:" <> client_id
        csrf_token = get_csrf_token()

        html =
          TrellixWeb.AppComponents.add_card_button(%{column_id: id, csrf_token: csrf_token})
          |> render_component

        payload = %{html: html, opts: [mode: "inner", selector: "#column-#{id}-actions"]}
        Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
        resp(conn, 200, "Ok")

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def column_card_create_submit(conn, %{"id" => id, "cardTitle" => title}) do
    case authorize_column_access(conn, id) do
      {:ok, user, column} ->
        client_id = get_session(conn, :client_id)
        topic = "client:" <> client_id
        csrf_token = get_csrf_token()

        position = Enum.count(column.cards)

        case Cards.create_card(%{
               title: title,
               column_id: id,
               position: position + 1,
               user_id: user.id
             }) do
          {:ok, card} ->
            html =
              TrellixWeb.AppComponents.card(%{
                card: card,
                csrf_token: csrf_token
              })
              |> render_component

            payload = %{html: html, opts: [mode: "append", selector: "#column-#{id}-cards"]}
            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})

          {:error, error} ->
            IO.inspect(error)
        end

        html =
          TrellixWeb.AppComponents.add_card_button(%{column_id: id, csrf_token: csrf_token})
          |> render_component

        payload = %{html: html, opts: [mode: "inner", selector: "#column-#{id}-actions"]}
        Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
        resp(conn, 200, "Ok")

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def column_card_delete(conn, %{"id" => id}) do
    client_id = get_session(conn, :client_id)
    topic = "client:" <> client_id

    case authorize_card_access(conn, id) do
      {:ok, _user, card} ->
        case Cards.delete_card(card) do
          {:ok, _struct} ->
            payload = %{html: nil, opts: [mode: "remove", selector: "#card-#{card.id}"]}
            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})
            resp(conn, 200, "OK")

          {:error, _changeset} ->
            resp(conn, 500, "Error")
        end

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  def card_reorder(conn, %{"id" => card_id, "columnId" => new_column_id, "newIndex" => new_index}) do
    csrf_token = get_csrf_token()

    case authorize_column_access(conn, new_column_id) do
      {:ok, user, _new_column} ->
        case Cards.get_card(card_id) do
          nil ->
            resp(conn, 404, "Not Found")

          card ->
            case authorize_column_access(conn, card.column_id) do
              {:ok, ^user, _old_column} ->
                client_id = get_session(conn, :client_id)
                topic = "client:" <> client_id

                case Cards.reorder_card(card_id, new_column_id, String.to_integer(new_index)) do
                  {:ok, {_updated_card, old_column_id}} ->
                    # Broadcast updated columns HTML to the current client
                    columns_to_update =
                      if old_column_id == new_column_id do
                        [new_column_id]
                      else
                        [old_column_id, new_column_id]
                      end

                    Enum.each(columns_to_update, fn column_id ->
                      column = Columns.get_column(column_id)

                      if column do
                        html =
                          TrellixWeb.AppComponents.column(%{
                            column: column,
                            csrf_token: csrf_token
                          })
                          |> render_component

                        payload = %{
                          html: html,
                          opts: [mode: "outer", selector: "#column-#{column_id}"]
                        }

                        Phoenix.PubSub.broadcast(
                          Trellix.PubSub,
                          topic,
                          {:patch_elements, payload}
                        )
                      end
                    end)

                    resp(conn, 200, "OK")

                  {:error, _changeset} ->
                    resp(conn, 500, "Error")
                end

              {:error, :unauthorized} ->
                resp(conn, 401, "Unauthorized")

              {:error, :not_found} ->
                resp(conn, 404, "Not Found")
            end
        end

      {:error, :unauthorized} ->
        resp(conn, 401, "Unauthorized")

      {:error, :not_found} ->
        resp(conn, 404, "Not Found")
    end
  end

  defp render_component(component) do
    component
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp get_current_user(conn) do
    client_id = get_session(conn, :client_id)

    case Users.get_user_by_session_id(client_id) do
      nil ->
        {:error, :not_found}

      user ->
        {:ok, user}
    end
  end

  defp authorize_board_access(conn, board_id) do
    case get_current_user(conn) do
      {:ok, user} ->
        case Boards.get_board_by_user(board_id, user.id) do
          nil -> {:error, :not_found}
          board -> {:ok, user, board}
        end

      {:error, :not_found} ->
        {:error, :unauthorized}
    end
  end

  defp authorize_column_access(conn, column_id) do
    case get_current_user(conn) do
      {:ok, user} ->
        column = Columns.get_user_column(user.id, column_id)

        case column do
          nil ->
            {:error, :not_found}

          column ->
            {:ok, user, column}
        end

      {:error, :not_found} ->
        {:error, :unauthorized}
    end
  end

  defp authorize_card_access(conn, card_id) do
    case get_current_user(conn) do
      {:ok, user} ->
        card = Cards.get_card(card_id)

        case card do
          nil ->
            {:error, :not_found}

          card ->
            {:ok, user, card}
        end

      {:error, :not_found} ->
        {:error, :unauthorized}
    end
  end
end
