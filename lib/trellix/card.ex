defmodule Trellix.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trellix_cards" do
    field :title, :string
    field :position, :decimal
    belongs_to :column, Trellix.Column
    belongs_to :user, Trellix.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:title, :position, :column_id, :user_id])
    |> validate_required([:title, :position, :column_id, :user_id])
    |> foreign_key_constraint(:column_id)
    |> foreign_key_constraint(:user_id)
  end
end
