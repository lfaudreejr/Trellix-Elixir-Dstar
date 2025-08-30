defmodule Trellix.Repo.Migrations.CreateBoards do
  use Ecto.Migration

  def change do
    create table(:trellix_boards) do
      add :name, :string
      add :color, :string
      add :user_id, references(:trellix_users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:trellix_boards, [:user_id])
  end
end
