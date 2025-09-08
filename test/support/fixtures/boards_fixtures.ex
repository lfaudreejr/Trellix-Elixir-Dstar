defmodule Trellix.BoardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trellix.Boards` context.
  """

  import Trellix.UsersFixtures

  @doc """
  Generate a board.
  """
  def board_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, board} =
      attrs
      |> Enum.into(%{
        color: "some color",
        name: "some name",
        user_id: user.id
      })
      |> Trellix.Boards.create_board()

    board
  end
end
