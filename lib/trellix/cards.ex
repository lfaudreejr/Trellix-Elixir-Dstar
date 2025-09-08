defmodule Trellix.Cards do
  @moduledoc """
  The Cards context.
  """

  import Ecto.Query, warn: false
  alias Trellix.Repo

  alias Trellix.Cards.Card

  require Logger

  @doc """
  Returns the list of trellix_cards.

  ## Examples

      iex> list_trellix_cards()
      [%Card{}, ...]

  """
  def list_trellix_cards do
    Repo.all(Card)
  end

  @doc """
  Gets a single card.

  Raises `Ecto.NoResultsError` if the Card does not exist.

  ## Examples

      iex> get_card!(123)
      %Card{}

      iex> get_card!(456)
      ** (Ecto.NoResultsError)

  """
  def get_card!(id), do: Repo.get!(Card, id)

  def get_user_card(id, user_id) do
    Card
    |> where([c], c.user_id == ^user_id and c.id == ^id)
    |> Repo.one()
  end

  @doc """
  Creates a card.

  ## Examples

      iex> create_card(%{field: value})
      {:ok, %Card{}}

      iex> create_card(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_card(attrs) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a card.

  ## Examples

      iex> update_card(card, %{field: new_value})
      {:ok, %Card{}}

      iex> update_card(card, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_card(%Card{} = card, attrs) do
    card
    |> Card.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a card.

  ## Examples

      iex> delete_card(card)
      {:ok, %Card{}}

      iex> delete_card(card)
      {:error, %Ecto.Changeset{}}

  """
  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking card changes.

  ## Examples

      iex> change_card(card)
      %Ecto.Changeset{data: %Card{}}

  """
  def change_card(%Card{} = card, attrs \\ %{}) do
    Card.changeset(card, attrs)
  end

  def reorder_cards(card_id, new_column_id, target_index) do
    Repo.transaction(fn ->
      card = Repo.get!(Card, card_id)
      old_column_id = card.column_id

      # Get ordered cards in target column (excluding moved card if same column)
      target_cards = get_target_column_cards(new_column_id, card_id, old_column_id)

      # Get position boundaries
      {prev_position, next_position} = get_position_boundaries(target_cards, target_index)

      # Generate new position
      case generate_position(prev_position, next_position) do
        :needs_rebalancing ->
          # Rebalance entire column and retry
          rebalance_column(new_column_id)
          reorder_cards(card_id, new_column_id, target_index)

        new_position ->
          # Update card
          case update_card(card, %{column_id: new_column_id, position: new_position}) do
            {:ok, updated_card} ->
              # Only rebalance old column if it's a cross-column move and needs rebalancing
              if old_column_id != new_column_id and should_rebalance_column?(old_column_id) do
                rebalance_column(old_column_id)
              end

              {:ok, updated_card}

            {:error, changeset} ->
              Repo.rollback(changeset)
          end
      end
    end)
  end

  defp generate_position(prev_position, next_position) do
    case {prev_position, next_position} do
      # First card in empty column
      {nil, nil} ->
        Decimal.new("10000")

      # Insert at beginning  
      {nil, next_pos} ->
        Decimal.div(next_pos, Decimal.new("2"))

      # Insert at end
      {prev_pos, nil} ->
        Decimal.add(prev_pos, Decimal.new("10000"))

      # Insert between two cards
      {prev_pos, next_pos} ->
        calculate_midpoint(prev_pos, next_pos)
    end
  end

  defp calculate_midpoint(prev_pos, next_pos) do
    diff = Decimal.sub(next_pos, prev_pos)

    # If difference is too small, trigger rebalancing
    if Decimal.compare(diff, Decimal.new("0.001")) == :lt do
      :needs_rebalancing
    else
      Decimal.add(prev_pos, Decimal.div(diff, Decimal.new("2")))
    end
  end

  defp get_target_column_cards(column_id, moved_card_id, old_column_id) do
    query =
      from(c in Card,
        where: c.column_id == ^column_id,
        order_by: [asc: c.position]
      )

    # Exclude moved card if it's a same-column operation
    query =
      if column_id == old_column_id do
        from(c in query, where: c.id != ^moved_card_id)
      else
        query
      end

    Repo.all(query)
  end

  defp get_position_boundaries(cards, target_index) do
    prev_card = if target_index > 0, do: Enum.at(cards, target_index - 1), else: nil
    next_card = Enum.at(cards, target_index)

    prev_position = if prev_card, do: prev_card.position, else: nil
    next_position = if next_card, do: next_card.position, else: nil

    {prev_position, next_position}
  end

  def get_cards_in_column(column_id) do
    from(c in Card,
      where: c.column_id == ^column_id,
      order_by: [asc: c.position]
    )
    |> Repo.all()
  end

  defp rebalance_column(column_id) do
    cards = get_cards_in_column(column_id)

    cards
    |> Enum.with_index()
    |> Enum.each(fn {card, index} ->
      # Use increments of 10000 for plenty of space
      new_position = Decimal.new((index + 1) * 10000)
      update_card(card, %{position: new_position})
    end)
  end

  defp should_rebalance_column?(column_id) do
    cards = get_cards_in_column(column_id)

    # Check if any adjacent cards have positions too close together
    cards
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.any?(fn [card1, card2] ->
      diff = Decimal.sub(card2.position, card1.position)
      Decimal.compare(diff, Decimal.new("1")) == :lt
    end)
  end

  def create_card_at_end(column_id, attrs) do
    # Get last card in column
    last_card = get_last_card_in_column(column_id)

    # Generate position at end
    position =
      case last_card do
        nil -> Decimal.new("10000")
        card -> Decimal.add(card.position, Decimal.new("10000"))
      end

    attrs = Map.put(attrs, :position, position)

    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
  end

  defp get_last_card_in_column(column_id) do
    from(c in Card,
      where: c.column_id == ^column_id,
      order_by: [desc: c.position],
      limit: 1
    )
    |> Repo.one()
  end
end
