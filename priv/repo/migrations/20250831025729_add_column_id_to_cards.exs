defmodule Trellix.Repo.Migrations.AddColumnIdToCards do
  use Ecto.Migration

  def change do
    alter table(:trellix_cards) do
      add :column_id, references(:trellix_columns, on_delete: :delete_all), null: false
    end

    create index(:trellix_cards, [:column_id])
  end
end
