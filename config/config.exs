# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../apps/mishka_html/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :mishka_translator, MishkaTranslator.Gettext,
  default_locale: "fa",
  locales: ~w(en fa)


config :mishka_api, :auth,
  token_type: :jwt_token

config :mishka_database, ecto_repos: [MishkaDatabase.Repo]

# ueberauth config can delete in developer pkg
config :ueberauth, Ueberauth,
base_path: "/auth",
providers: [
   # For now, we need normal information of a user, but in the future it  should be possible to use dynamic default_scope
   # /auth/github?scope=user,public_repo
  github: {Ueberauth.Strategy.Github, [default_scope: "read:user", send_redirect_uri: false]},
  google: {Ueberauth.Strategy.Google, [
     default_scope:
     "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile"
   ]}
]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
   client_id: System.get_env("GITHUB_CLIENT_ID"),
   client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
   client_id: System.get_env("GOOGLE_CLIENT_ID"),
   client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
   redirect_uri: System.get_env("GOOGLE_REDIRECT_URI")




config :mishka_database, MishkaDatabase.Repo,
  database: System.get_env("DATABASE_NAME") || "mishka_test",
  username: System.get_env("DATABASE_USER") || "postgres",
  password: System.get_env("DATABASE_PASSWORD") || "postgres",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool_size: 10,
  show_sensitive_data_on_connection_error: true

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
  "k" => "#{System.get_env("TOKEN_JWT_KEY")}",
  "kty" => "oct",
  "use" => "sig"
}

email_config = [
  adapter: Bamboo.SMTPAdapter,
  server: System.get_env("EMAIL_SERVER"),
  hostname: System.get_env("EMAIL_HOSTNAME"),
  username: System.get_env("EMAIL_USERNAME"),
  password: System.get_env("EMAIL_PASSWORD"),
  retries: 1,
  no_mx_lookups: true,
  auth: :always
]
if System.get_env("EMAIL_PORT") == "587" or is_nil(System.get_env("EMAIL_PORT")) do
  config :mishka_content, MishkaContent.Email.Mailer,
    email_config ++ [port: 587, tls: :if_available, allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"]]
else
  config :mishka_content, MishkaContent.Email.Mailer, email_config ++ [port: 465, tls: :never, ssl: true,]
end

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :mishka_installer, :basic,
  repo: MishkaDatabase.Repo,
  pubsub: MishkaHtml.PubSub,
  html_router: MishkaHtmlWeb.Router.Helpers,
  project_path: System.get_env("PROJECT_PATH"),
  mix: MishkaInstaller.MixProject,
  mix_path: System.get_env("MIX_PATH"),
  gettext: MishkaTranslator.Gettext


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
