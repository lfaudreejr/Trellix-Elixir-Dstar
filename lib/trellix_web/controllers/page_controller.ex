defmodule TrellixWeb.PageController do
  use TrellixWeb, :controller

  alias Trellix.Users

  def home(conn, _params) do
    session_id = get_session(conn, :client_id)
    csrf_token = get_csrf_token()

    user =
      case Users.get_user_by_session_id(session_id) do
        nil ->
          case Users.create_user(%{session_id: session_id}) do
            {:ok, user} ->
              # Preload boards for newly created user to match the existing user
              Trellix.Repo.preload(user, :boards)

            {:error, _changeset} ->
              nil
          end

        user ->
          user
      end

    render(conn, :home, user: user, csrf_token: csrf_token)
  end
end
