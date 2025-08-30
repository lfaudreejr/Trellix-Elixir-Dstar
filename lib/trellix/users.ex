defmodule Trellix.Users do
  import Ecto.Query, warn: false
  alias Trellix.Repo
  alias Trellix.User

  def get_user_by_session_id(session_id) do
    User
    |> preload(boards: [columns: [:cards]])
    |> where([u], u.session_id == ^session_id)
    |> Repo.one()
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
