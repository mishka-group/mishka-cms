# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
# config :mishka_html, MishkaHtmlWeb.Endpoint,
#   url: [host: "localhost"],
#   secret_key_base: "afY0EvH0QD34GEhkEiXGjDAnxp9lskQjRbMQ1K8v69t3ZzPCK8RU+rbD4K3E3yHa",
#   render_errors: [view: MishkaHtmlWeb.ErrorView, accepts: ~w(html json), layout: false],
#   pubsub_server: MishkaHtml.PubSub,
#   live_view: [signing_salt: "wqSr52l4"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
