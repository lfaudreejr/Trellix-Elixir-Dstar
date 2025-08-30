defmodule TrellixWeb.UsersTest do
  use Trellix.DataCase, async: true
  alias Trellix.Users
  alias Trellix.Boards
  alias Trellix.Columns
  alias Trellix.Cards

  test "create a user" do
    session_id = "123"
    {:ok, user} = Users.create_user(%{session_id: session_id})
    assert user.session_id == session_id
  end

  test "get user by session_id" do
    session_id = "123"
    {:ok, _} = Users.create_user(%{session_id: session_id})
    user = Users.get_user_by_session_id(session_id)
    assert user.session_id == session_id
  end

  test "get user pulls all data" do
    session_id = "123"
    {:ok, user} = Users.create_user(%{session_id: session_id})
    {:ok, board} = Boards.create_board(%{user_id: user.id, name: "test board", color: "blue"})

    {:ok, column} =
      Columns.create_column(%{
        board_id: board.id,
        name: "test column",
        position: 0,
        user_id: user.id
      })

    {:ok, card} =
      Cards.create_card(%{
        column_id: column.id,
        title: "test card",
        position: 0,
        user_id: user.id
      })

    user = Users.get_user_by_session_id(session_id)

    user_board = Enum.at(user.boards, 0)
    user_board_column = Enum.at(user_board.columns, 0)
    user_board_column_card = Enum.at(user_board_column.cards, 0)

    assert user_board.id == board.id
    assert user_board_column.id == column.id
    assert user_board_column_card.id == card.id
  end
end
