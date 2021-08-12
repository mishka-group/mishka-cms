defmodule MishkaDatabase.Repo do
  use Ecto.Repo,
    otp_app: :mishka_database,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 20
end
