# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
# config :mishka_api, MishkaApiWeb.Endpoint,
#   url: [host: "localhost"],
#   secret_key_base: "qP5c9diga3k115/empFNEEi/fgwXkhArZvpvFaiLqdi3Um1ntPh0P2AkleLzEpzY",
#   render_errors: [view: MishkaApiWeb.ErrorView, accepts: ~w(json), layout: false],
#   pubsub_server: MishkaApi.PubSub,
#   live_view: [signing_salt: "e1v5FAl7"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
