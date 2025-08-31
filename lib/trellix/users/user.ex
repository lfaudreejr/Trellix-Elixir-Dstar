defmodule Trellix.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trellix_users" do
    field :session_id, :string
    has_many :boards, Trellix.Boards.Board

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:session_id])
    |> validate_required([:session_id])
  end
end
