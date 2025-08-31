defmodule Trellix.Repo.Migrations.CreateTrellixUsers do
  use Ecto.Migration

  def change do
    create table(:trellix_users) do
      add :session_id, :string

      timestamps(type: :utc_datetime)
    end
  end
end
