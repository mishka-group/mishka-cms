# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

secret_key_base_html =
  System.get_env("SECRET_KEY_BASE_HTML") ||
    raise """
    environment variable SECRET_KEY_BASE_HTML is missing.
    You can generate one by calling: mix phx.gen.secret
    """

secret_key_base_api =
  System.get_env("SECRET_KEY_BASE_API") ||
    raise """
    environment variable SECRET_KEY_BASE_API is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :mishka_html, MishkaHtmlWeb.Endpoint,
    url: [scheme: System.get_env("PROTOCOL"), host: System.get_env("CMS_DOMAIN_NAME"), port: System.get_env("CMS_PORT")],
    http: [
      port: String.to_integer(System.get_env("PORT") || "4000"),
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base_html


config :mishka_api, MishkaApiWeb.Endpoint,
    url: [scheme: System.get_env("PROTOCOL"), host: System.get_env("API_DOMAIN_NAME"), port: System.get_env("API_PORT")],
    http: [
      port: String.to_integer(System.get_env("PORT") || "4001"),
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base_api

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :mishka_cms_web, MishkaCmsWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
