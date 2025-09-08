defmodule Trellix.CardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trellix.Cards` context.
  """

  import Trellix.UsersFixtures
  import Trellix.ColumnsFixtures

  @doc """
  Generate a card.
  """
  def card_fixture(attrs \\ %{}) do
    user = user_fixture()
    column = column_fixture()

    {:ok, card} =
      attrs
      |> Enum.into(%{
        position: "120.5",
        title: "some title",
        user_id: user.id,
        column_id: column.id
      })
      |> Trellix.Cards.create_card()

    card
  end
end
