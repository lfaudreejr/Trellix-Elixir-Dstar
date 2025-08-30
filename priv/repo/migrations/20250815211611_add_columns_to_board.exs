defmodule Trellix.Repo.Migrations.AddColumnsToBoard do
  use Ecto.Migration

  def change do
    alter table(:trellix_columns) do
      add :board_id, references(:trellix_boards, on_delete: :delete_all), null: false
    end

    create index(:trellix_columns, [:board_id])
  end
end
