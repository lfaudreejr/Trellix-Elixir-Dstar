defmodule Trellix.Boards do
  import Ecto.Query, warn: false
  alias Trellix.Repo
  alias Trellix.Board

  def get_board(id) do
    cards_query = from(card in Trellix.Card, order_by: [asc: card.position])

    columns_query =
      from(c in Trellix.Column,
        order_by: [asc: c.position],
        preload: [cards: ^cards_query]
      )

    Board
    |> preload(columns: ^columns_query)
    |> Repo.get(id)
  end

  def get_board_by_user(id, user_id) do
    cards_query = from(card in Trellix.Card, order_by: [asc: card.position])

    columns_query =
      from(c in Trellix.Column,
        order_by: [asc: c.position],
        preload: [cards: ^cards_query]
      )

    Board
    |> where([b], b.user_id == ^user_id)
    |> preload(columns: ^columns_query)
    |> Repo.get(id)
  end

  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  def update_board(%Board{} = board, attrs \\ %{}) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  def delete_board(%Board{} = board) do
    Repo.delete(board)
  end
end
