defmodule Trellix.ColumnsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trellix.Columns` context.
  """

  import Trellix.UsersFixtures
  import Trellix.BoardsFixtures

  @doc """
  Generate a column.
  """
  def column_fixture(attrs \\ %{}) do
    user = user_fixture()
    board = board_fixture()

    {:ok, column} =
      attrs
      |> Enum.into(%{
        name: "some name",
        position: "120.5",
        board_id: board.id,
        user_id: user.id
      })
      |> Trellix.Columns.create_column()

    column
  end
end
