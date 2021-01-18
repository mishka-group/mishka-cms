# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

config :mishka_database, MishkaDatabase.Repo,
  database: "mishka_database_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10,
  show_sensitive_data_on_connection_error: true


config :mishka_database, ecto_repos: [MishkaDatabase.Repo]


# config :mishka_html_web,
#   generators: [context_app: :mishka_html]

# # Configures the endpoint
config :mishka_html, MishkaHtmlWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "afY0EvH0QD34GEhkEiXGjDAnxp9lskQjRbMQ1K8v69t3ZzPCK8RU+rbD4K3E3yHa",
  render_errors: [view: MishkaHtmlWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MishkaHtml.PubSub,
  live_view: [signing_salt: "wqSr52l4"]


# config :mishka_api_web,
#     generators: [context_app: :mishka_api]


config :mishka_api, MishkaApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "qP5c9diga3k115/empFNEEi/fgwXkhArZvpvFaiLqdi3Um1ntPh0P2AkleLzEpzY",
  render_errors: [view: MishkaApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: MishkaApi.PubSub,
  live_view: [signing_salt: "e1v5FAl7"]




# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
