defmodule Trellix.Columns.Column do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trellix_columns" do
    field :name, :string
    field :position, :decimal
    belongs_to :board, Trellix.Boards.Board
    belongs_to :user, Trellix.Users.User
    has_many :cards, Trellix.Cards.Card

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:name, :position, :board_id, :user_id])
    |> validate_required([:name, :position, :board_id, :user_id])
    |> foreign_key_constraint(:board_id)
    |> foreign_key_constraint(:user_id)
  end
end
