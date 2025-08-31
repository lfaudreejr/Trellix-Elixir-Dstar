defmodule Trellix.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trellix.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        session_id: "some session_id"
      })
      |> Trellix.Users.create_user()

    user
  end
end
