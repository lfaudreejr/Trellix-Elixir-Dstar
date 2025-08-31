defmodule Trellix.Cards.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trellix_cards" do
    field :title, :string
    field :position, :decimal
    belongs_to :user, Trellix.Users.User
    belongs_to :column, Trellix.Columns.Column

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:title, :position, :user_id, :column_id])
    |> validate_required([:title, :position, :user_id, :column_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:column_id)
  end
end
