use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mishka_html, MishkaHtmlWeb.Endpoint,
  http: [port: 4002],
  server: false

config :mishka_api, MishkaApiWeb.Endpoint,
  http: [port: 4003],
  server: false


config :mishka_database, MishkaDatabase.Repo,
  username: "mishka_database_repo",
  password: "postgres",
  database: "mishka_database_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "postgresql",
  pool_size: 10,
  pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, level: :warn
