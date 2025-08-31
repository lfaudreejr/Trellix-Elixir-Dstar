defmodule Trellix.Repo.Migrations.CreateTrellixBoards do
  use Ecto.Migration

  def change do
    create table(:trellix_boards) do
      add :name, :string
      add :color, :string

      timestamps(type: :utc_datetime)
    end
  end
end
