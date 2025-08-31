defmodule Trellix.Repo.Migrations.AddUserIdToCards do
  use Ecto.Migration

  def change do
    alter table(:trellix_cards) do
      add :user_id, references(:trellix_users, on_delete: :delete_all), null: false
    end

    create index(:trellix_cards, [:user_id])
    create index(:trellix_cards, [:user_id, :id])
  end
end
