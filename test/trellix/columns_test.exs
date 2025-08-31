defmodule Trellix.ColumnsTest do
  use Trellix.DataCase

  alias Trellix.Columns

  describe "trellix_columns" do
    alias Trellix.Columns.Column

    import Trellix.ColumnsFixtures

    @invalid_attrs %{name: nil, position: nil}

    test "list_trellix_columns/0 returns all trellix_columns" do
      column = column_fixture()
      assert Columns.list_trellix_columns() == [column]
    end

    test "get_column!/1 returns the column with given id" do
      column = column_fixture()
      assert Columns.get_column!(column.id) == column
    end

    test "create_column/1 with valid data creates a column" do
      valid_attrs = %{name: "some name", position: "120.5"}

      assert {:ok, %Column{} = column} = Columns.create_column(valid_attrs)
      assert column.name == "some name"
      assert column.position == Decimal.new("120.5")
    end

    test "create_column/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Columns.create_column(@invalid_attrs)
    end

    test "update_column/2 with valid data updates the column" do
      column = column_fixture()
      update_attrs = %{name: "some updated name", position: "456.7"}

      assert {:ok, %Column{} = column} = Columns.update_column(column, update_attrs)
      assert column.name == "some updated name"
      assert column.position == Decimal.new("456.7")
    end

    test "update_column/2 with invalid data returns error changeset" do
      column = column_fixture()
      assert {:error, %Ecto.Changeset{}} = Columns.update_column(column, @invalid_attrs)
      assert column == Columns.get_column!(column.id)
    end

    test "delete_column/1 deletes the column" do
      column = column_fixture()
      assert {:ok, %Column{}} = Columns.delete_column(column)
      assert_raise Ecto.NoResultsError, fn -> Columns.get_column!(column.id) end
    end

    test "change_column/1 returns a column changeset" do
      column = column_fixture()
      assert %Ecto.Changeset{} = Columns.change_column(column)
    end
  end
end
