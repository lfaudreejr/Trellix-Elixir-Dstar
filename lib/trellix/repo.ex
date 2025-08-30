defmodule Trellix.Repo do
  use Ecto.Repo,
    otp_app: :trellix,
    adapter: Ecto.Adapters.Postgres
end
