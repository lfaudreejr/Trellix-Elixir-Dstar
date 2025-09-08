defmodule Trellix.BoardsTest do
  use Trellix.DataCase

  alias Trellix.Boards

  describe "trellix_boards" do
    alias Trellix.Boards.Board

    import Trellix.BoardsFixtures
    import Trellix.UsersFixtures

    @invalid_attrs %{name: nil, color: nil}

    test "list_trellix_boards/0 returns all trellix_boards" do
      board = board_fixture()
      assert Boards.list_trellix_boards() == [board]
    end

    test "get_board!/1 returns the board with given id" do
      board = board_fixture()
      assert Boards.get_board!(board.id) == board
    end

    test "create_board/1 with valid data creates a board" do
      user = user_fixture()
      valid_attrs = %{name: "some name", color: "some color", user_id: user.id}

      assert {:ok, %Board{} = board} = Boards.create_board(valid_attrs)
      assert board.name == "some name"
      assert board.color == "some color"
      assert board.user_id == user.id
    end

    test "create_board/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Boards.create_board(@invalid_attrs)
    end

    test "update_board/2 with valid data updates the board" do
      board = board_fixture()
      other_user = user_fixture()

      update_attrs = %{
        name: "some updated name",
        color: "some updated color",
        user_id: other_user.id
      }

      assert {:ok, %Board{} = board} = Boards.update_board(board, update_attrs)
      assert board.name == "some updated name"
      assert board.color == "some updated color"
      assert board.user_id == other_user.id
    end

    test "update_board/2 with invalid data returns error changeset" do
      board = board_fixture()
      assert {:error, %Ecto.Changeset{}} = Boards.update_board(board, @invalid_attrs)
      assert board == Boards.get_board!(board.id)
    end

    test "delete_board/1 deletes the board" do
      board = board_fixture()
      assert {:ok, %Board{}} = Boards.delete_board(board)
      assert_raise Ecto.NoResultsError, fn -> Boards.get_board!(board.id) end
    end

    test "change_board/1 returns a board changeset" do
      board = board_fixture()
      assert %Ecto.Changeset{} = Boards.change_board(board)
    end
  end
end
