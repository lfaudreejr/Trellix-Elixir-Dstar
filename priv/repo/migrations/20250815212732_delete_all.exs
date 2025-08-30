defmodule Trellix.Repo.Migrations.DeleteAll do
  use Ecto.Migration

  def change do
    alter table(:trellix_cards) do
      modify :column_id, references(:trellix_columns, on_delete: :delete_all),
        from: references(:trellix_columns, on_delete: :nothing)
    end

    alter table(:trellix_boards) do
      modify :user_id, references(:trellix_users, on_delete: :delete_all),
        from: references(:trellix_users, on_delete: :nothing)
    end
  end
end
