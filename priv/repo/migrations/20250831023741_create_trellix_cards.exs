defmodule Trellix.Repo.Migrations.CreateTrellixCards do
  use Ecto.Migration

  def change do
    create table(:trellix_cards) do
      add :title, :string
      add :position, :decimal

      timestamps(type: :utc_datetime)
    end
  end
end
