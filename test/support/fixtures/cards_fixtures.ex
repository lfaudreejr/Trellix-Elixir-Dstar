defmodule Trellix.CardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trellix.Cards` context.
  """

  @doc """
  Generate a card.
  """
  def card_fixture(attrs \\ %{}) do
    {:ok, card} =
      attrs
      |> Enum.into(%{
        position: "120.5",
        title: "some title",
        user_id: 123,
        column_id: 123
      })
      |> Trellix.Cards.create_card()

    card
  end
end
