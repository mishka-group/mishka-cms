defmodule MishkaDatabase.Repo do
  use Ecto.Repo,
    otp_app: :mishka_database,
    adapter: Ecto.Adapters.Postgres
end
