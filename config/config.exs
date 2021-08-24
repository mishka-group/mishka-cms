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

config :mishka_translator, MishkaTranslator.Gettext,
  default_locale: "fa",
  locales: ~w(en fa)


config :mishka_api, :auth,
token_type: :jwt_token


config :mishka_database, MishkaDatabase.Repo,
  database: "mishka_database_repo",
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  hostname: "postgresql",
  pool_size: 10,
  show_sensitive_data_on_connection_error: true


config :mishka_database, ecto_repos: [MishkaDatabase.Repo]


# # Configures the endpoint
config :mishka_html, MishkaHtmlWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE_HTML"),
  render_errors: [view: MishkaHtmlWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MishkaHtml.PubSub,
  live_view: [signing_salt: System.get_env("LIVE_VIEW_SALT")]



config :mishka_api, MishkaApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE_API"),
  render_errors: [view: MishkaApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: MishkaApi.PubSub



config :mishka_user, MishkaUser.Guardian,
  issuer: "mishka_user",
  allowed_algos: ["HS256"],
  secret_key: %{
  "alg" => "HS256",
  # "k" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9",
  "k" => "Exe6Qk6YPWWNmOS7rAtXQfPPngruPtEIivDB1nsXwSk",
  "kty" => "oct",
  "use" => "sig"
}

config :mishka_content, MishkaContent.Email.Mailer,
  adapter: Bamboo.LocalAdapter
  # server: "",
  # hostname: "",
  # port: 587,
  # username: "",
  # password: "",
  # tls: :if_available,
  # allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  # # ssl: true,
  # retries: 1,
  # no_mx_lookups: true,
  # auth: :always


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
