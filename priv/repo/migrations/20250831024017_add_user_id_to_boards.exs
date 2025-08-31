defmodule Trellix.Repo.Migrations.AddUserIdToBoards do
  use Ecto.Migration

  def change do
    alter table(:trellix_boards) do
      add :user_id, references(:trellix_users, on_delete: :delete_all), null: false
    end

    create index(:trellix_boards, [:user_id])
    create index(:trellix_boards, [:user_id, :id])
  end
end
