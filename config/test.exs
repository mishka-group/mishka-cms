import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mishka_html, MishkaHtmlWeb.Endpoint,
  http: [port: 4002],
  server: false

config :mishka_api, MishkaApiWeb.Endpoint,
  http: [port: 4003],
  server: false

config :mishka_database, ecto_repos: [MishkaDatabase.Repo]

config :mishka_database, MishkaDatabase.Repo,
  url: System.get_env("DATABASE_URL") || "ecto://postgres:postgres@localhost/mishka_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 30,
  queue_target: 10000,
  show_sensitive_data_on_connection_error: true

# Print only warnings and errors during test
config :logger, level: :warn
