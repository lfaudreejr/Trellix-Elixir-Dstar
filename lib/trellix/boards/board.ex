defmodule Trellix.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trellix_boards" do
    field :name, :string
    field :color, :string
    belongs_to :user, Trellix.Users.User
    has_many :columns, Trellix.Columns.Column

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :color, :user_id])
    |> validate_required([:name, :color, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
