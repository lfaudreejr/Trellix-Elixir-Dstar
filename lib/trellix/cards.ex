defmodule Trellix.Cards do
  import Ecto.Query, warn: false
  alias Trellix.Repo
  alias Trellix.Card

  def create_card(attrs \\ %{}) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
  end

  def update_card(%Card{} = card, attrs \\ %{}) do
    card
    |> Card.changeset(attrs)
    |> Repo.update()
  end

  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end

  def get_card(id) do
    Repo.get(Card, id)
  end

  def reorder_card(card_id, new_column_id, new_position) do
    Repo.transaction(fn ->
      card = Repo.get!(Card, card_id)
      old_column_id = card.column_id

      # Calculate the new position based on the target index, excluding the card being moved
      position = calculate_position(new_column_id, new_position, card_id)

      # Update the card with new column and position
      case update_card(card, %{column_id: new_column_id, position: position}) do
        {:ok, updated_card} ->
          # Reorder cards in the old column if it's different
          if old_column_id != new_column_id do
            reorder_cards_in_column(old_column_id)
          end

          # Reorder cards in the new column
          reorder_cards_in_column(new_column_id)

          {updated_card, old_column_id}

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  defp calculate_position(column_id, target_index, card_being_moved_id \\ nil) do
    # Get cards in column, excluding the card being moved for same-column operations
    cards = get_cards_in_column_excluding(column_id, card_being_moved_id)

    case {target_index, length(cards)} do
      # If it's the first position or no cards exist
      {0, 0} ->
        Decimal.new(1)

      {0, _} ->
        # Insert before the first card
        first_card = List.first(cards)

        if Decimal.compare(first_card.position, Decimal.new(1)) == :gt do
          # If first card position > 1, use position 1
          Decimal.new(1)
        else
          # Insert before first card by dividing its position by 2
          Decimal.div(first_card.position, Decimal.new(2))
        end

      # If it's the last position
      {index, count} when index >= count ->
        case List.last(cards) do
          nil -> Decimal.new(1)
          last_card -> Decimal.add(last_card.position, Decimal.new(1))
        end

      # If it's in the middle, insert between two cards
      {index, _} ->
        prev_card = Enum.at(cards, index - 1)
        next_card = Enum.at(cards, index)

        prev_pos = if prev_card, do: prev_card.position, else: Decimal.new(0)
        next_pos = next_card.position

        # Calculate midpoint
        Decimal.add(prev_pos, next_pos)
        |> Decimal.div(Decimal.new(2))
    end
  end

  defp get_cards_in_column(column_id) do
    from(c in Card,
      where: c.column_id == ^column_id,
      order_by: [asc: c.position]
    )
    |> Repo.all()
  end

  defp get_cards_in_column_excluding(column_id, card_id_to_exclude) do
    query =
      from(c in Card,
        where: c.column_id == ^column_id,
        order_by: [asc: c.position]
      )

    query =
      if card_id_to_exclude do
        from(c in query, where: c.id != ^card_id_to_exclude)
      else
        query
      end

    Repo.all(query)
  end

  defp reorder_cards_in_column(column_id) do
    cards = get_cards_in_column(column_id)

    cards
    |> Enum.with_index(1)
    |> Enum.each(fn {card, index} ->
      new_position = Decimal.new(index)
      update_card(card, %{position: new_position})
    end)
  end

  def get_user_card(user_id, card_id) do
    Repo.get_by(Card, id: card_id, user_id: user_id)
  end
end
