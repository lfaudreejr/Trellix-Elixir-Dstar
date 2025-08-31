defmodule Trellix.ColumnsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trellix.Columns` context.
  """

  @doc """
  Generate a column.
  """
  def column_fixture(attrs \\ %{}) do
    {:ok, column} =
      attrs
      |> Enum.into(%{
        name: "some name",
        position: "120.5",
        board_id: 123,
        user_id: 123
      })
      |> Trellix.Columns.create_column()

    column
  end
end
