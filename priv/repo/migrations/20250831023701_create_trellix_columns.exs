defmodule Trellix.Repo.Migrations.CreateTrellixColumns do
  use Ecto.Migration

  def change do
    create table(:trellix_columns) do
      add :name, :string
      add :position, :decimal

      timestamps(type: :utc_datetime)
    end
  end
end
