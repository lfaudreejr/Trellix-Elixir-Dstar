defmodule Trellix.Repo.Migrations.AddUserIdToColumns do
  use Ecto.Migration

  def change do
    alter table(:trellix_columns) do
      add :user_id, references(:trellix_users, on_delete: :delete_all), null: false
    end

    create index(:trellix_columns, [:user_id])
    create index(:trellix_columns, [:user_id, :id])
  end
end
