defmodule Trellix.BoardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trellix.Boards` context.
  """

  @doc """
  Generate a board.
  """
  def board_fixture(attrs \\ %{}) do
    {:ok, board} =
      attrs
      |> Enum.into(%{
        color: "some color",
        name: "some name",
        user_id: 123
      })
      |> Trellix.Boards.create_board()

    board
  end
end
