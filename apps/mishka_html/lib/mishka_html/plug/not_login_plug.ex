defmodule MishkaHtml.Plug.NotLoginPlug do
  import Plug.Conn
  use MishkaHtmlWeb, :controller
  alias MishkaUser.Token.CurrentPhoenixToken
  alias MishkaHtmlWeb.Router.Helpers, as: Routes
  require MishkaTranslator.Gettext

  def init(default), do: default

  def call(conn, _default) do
    user_ip = to_string(:inet_parse.ntoa(conn.remote_ip))

    case CurrentPhoenixToken.verify_token(get_session(conn, :current_token), :current) do
      {:ok, :verify_token, :current, current_token_info} ->
        on_user_login_failure(conn, user_ip, {:ok, :verify_token, :current, current_token_info}).conn

        conn
        |> put_flash(
          :error,
          MishkaTranslator.Gettext.dgettext("html_auth", "شما از قبل وارد سایت شده اید.")
        )
        |> redirect(to: Routes.live_path(conn, MishkaHtmlWeb.HomeLive))
        |> halt()

      _ ->
        conn
    end
  end

  defp on_user_login_failure(conn, user_ip, error) do
    state = %MishkaInstaller.Reference.OnUserLoginFailure{
      conn: conn,
      ip: user_ip,
      endpoint: :html,
      error: error
    }

    MishkaInstaller.Hook.call(event: "on_user_login_failure", state: state)
  end
end
