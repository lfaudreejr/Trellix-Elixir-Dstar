defmodule TrellixWeb.ColumnController do
  use TrellixWeb, :controller

  require Logger

  alias Trellix.Cards
  alias TrellixWeb.ColumnComponents
  alias Trellix.Columns
  alias TrellixWeb.Utils

  def change_name(conn, %{"column_id" => column_id, "column_name" => column_name}) do
    case Utils.authorize_column_access(conn, column_id) do
      {:error, _} ->
        Logger.info("Column Change Name - Session Unauthenticated")
        resp(conn, 401, "Unauthorized")

      {:ok, user, column} ->
        csrf_token = get_csrf_token()
        topic = "client:" <> user.session_id

        case Columns.update_column(column, %{name: column_name}) do
          {:error, _} ->
            Logger.info("Column Change Name - Error Updating Column")
            resp(conn, 500, "Server Error")

          {:ok, column} ->
            html =
              Utils.render_component(
                ColumnComponents.column_name_input(%{
                  column: column,
                  csrf_token: csrf_token
                })
              )

            payload = %{
              html: html,
              opts: [mode: "replace", selector: "#column-#{column.id}-name"]
            }

            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})

            resp(conn, 200, "OK")
        end
    end
  end

  def get_create_column_card_form(conn, %{"column_id" => column_id}) do
    case Utils.authorize_column_access(conn, column_id) do
      {:error, _} ->
        Logger.info("Get Column Create Card Form - Session Unauthenticated")
        resp(conn, 401, "Unauthorized")

      {:ok, user, column} ->
        csrf_token = get_csrf_token()
        topic = "client:" <> user.session_id

        html =
          Utils.render_component(
            ColumnComponents.add_card_form(%{
              column_id: column.id,
              csrf_token: csrf_token
            })
          )

        payload = %{
          html: html,
          opts: [mode: "inner", selector: "#column-#{column.id}-actions"]
        }

        Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})

        resp(conn, 200, "Ok")
    end
  end

  def post_create_column_card_form(conn, %{"column_id" => column_id, "title" => card_title}) do
    case Utils.authorize_column_access(conn, column_id) do
      {:error, _} ->
        Logger.info("Post Column Create Card Form - Session Unauthenticated")
        resp(conn, 401, "Unauthorized")

      {:ok, user, column} ->
        case Cards.create_card_at_end(column.id, %{
               title: card_title,
               column_id: column.id,
               user_id: user.id
             }) do
          {:error, _} ->
            Logger.info("Post Column Create Card From - Create Card Failed")
            resp(conn, 500, "Server Error")

          {:ok, card} ->
            csrf_token = get_csrf_token()
            topic = "client:" <> user.session_id

            html =
              Utils.render_component(
                ColumnComponents.column_card(%{
                  card: card,
                  column: column,
                  csrf_token: csrf_token
                })
              )

            payload = %{
              html: html,
              opts: [mode: "append", selector: "#column-#{column.id}-cards"]
            }

            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})

            html =
              Utils.render_component(
                ColumnComponents.add_card_button(%{
                  column_id: column.id
                })
              )

            payload = %{
              html: html,
              opts: [mode: "inner", selector: "#column-#{column.id}-actions"]
            }

            Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})

            resp(conn, 200, "OK")
        end
    end
  end

  def get_column_card_create_button(conn, %{"column_id" => column_id}) do
    case Utils.authorize_column_access(conn, column_id) do
      {:error, _} ->
        Logger.info("Get Column Create Card Button - Session Unauthenticated")
        resp(conn, 401, "Unauthorized")

      {:ok, user, column} ->
        topic = "client:" <> user.session_id

        html =
          Utils.render_component(
            ColumnComponents.add_card_button(%{
              column_id: column.id
            })
          )

        payload = %{
          html: html,
          opts: [mode: "inner", selector: "#column-#{column.id}-actions"]
        }

        Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})

        resp(conn, 200, "Ok")
    end
  end

  def delete_column_card(conn, %{"id" => id, "column_id" => column_id}) do
    case Utils.authorize_column_access(conn, column_id) do
      {:error, _} ->
        Logger.info("Delete Column Card - Session Unauthenticated")
        resp(conn, 401, "Unauthorized")

      {:ok, user, _} ->
        case Cards.get_user_card(id, user.id) do
          nil ->
            Logger.info("Delete Column Card - Card Not Found")
            resp(conn, 404, "Not Found")

          card ->
            case Cards.delete_card(card) do
              {:error, _} ->
                Logger.info("Delete Column Card - Delete Failed")
                resp(conn, 500, "Server Error")

              {:ok, _} ->
                topic = "client:" <> user.session_id

                payload = %{html: nil, opts: [mode: "remove", selector: "#card-#{card.id}"]}

                Phoenix.PubSub.broadcast(Trellix.PubSub, topic, {:patch_elements, payload})

                resp(conn, 200, "OK")
            end
        end
    end
  end

  def column_card_reorder(conn, %{"id" => id, "column_id" => column_id, "new_index" => new_index}) do
    case Utils.authorize_column_access(conn, column_id) do
      {:error, _} ->
        Logger.info("Column Card Reorder - Session Unauthenticated")
        resp(conn, 401, "Unauthorized")

      {:ok, user, _} ->
        case Cards.get_user_card(id, user.id) do
          nil ->
            Logger.info("Column Card Reorder - Card Not Found")
            resp(conn, 404, "Not Found")

          card ->
            new_index_int = String.to_integer(new_index)

            case Cards.reorder_cards(card.id, column_id, new_index_int) do
              {:error, _} ->
                resp(conn, 500, "Server Error")

              {:ok, _} ->
                resp(conn, 200, "OK")
            end
        end
    end
  end
end
