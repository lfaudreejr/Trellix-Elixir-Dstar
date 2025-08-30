defmodule Trellix.Columns do
  import Ecto.Query, warn: false
  alias Trellix.Repo
  alias Trellix.Column

  def create_column(attrs \\ %{}) do
    %Column{}
    |> Column.changeset(attrs)
    |> Repo.insert()
  end

  def get_column(id) do
    cards_query = from(c in Trellix.Card, order_by: [asc: c.position])

    Column
    |> preload(cards: ^cards_query)
    |> Repo.get(id)
  end

  def update_column(%Column{} = column, attrs \\ %{}) do
    column
    |> Column.changeset(attrs)
    |> Repo.update()
  end

  def get_user_column(user_id, column_id) do
    cards_query = from(c in Trellix.Card, order_by: [asc: c.position])

    Column
    |> preload(cards: ^cards_query)
    |> Repo.get_by(id: column_id, user_id: user_id)
  end
end
