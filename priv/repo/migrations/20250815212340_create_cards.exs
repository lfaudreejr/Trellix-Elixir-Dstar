defmodule Trellix.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:trellix_cards) do
      add :title, :string
      add :position, :decimal
      add :column_id, references(:trellix_columns, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:trellix_cards, [:column_id])
  end
end
