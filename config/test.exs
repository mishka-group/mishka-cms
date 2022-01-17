import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mishka_html, MishkaHtmlWeb.Endpoint,
  http: [port: 4002],
  server: false

config :mishka_api, MishkaApiWeb.Endpoint,
  http: [port: 4003],
  server: false

config :mishka_database, MishkaDatabase.Repo,
  username: System.get_env("DATABASE_USER"),
  password: System.get_env("DATABASE_PASSWORD"),
  database: "#{System.get_env("DATABASE_NAME")}_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: System.get_env("DATABASE_HOST"),
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox

IO.inspect(System.get_env("GITHUB_ACTIONS"))
if System.get_env("GITHUB_ACTIONS") do
  config :mishka_database, MishkaDatabase.Repo, hostname: "localhost"
end
# Print only warnings and errors during test
config :logger, level: :warn
