defmodule MishkaHtml.Plug.NotLoginPlug do
  import Plug.Conn
  use MishkaHtmlWeb, :controller
  alias MishkaUser.Token.CurrentPhoenixToken
  alias MishkaHtmlWeb.Router.Helpers, as: Routes
  require MishkaTranslator.Gettext

  def init(default), do: default

  def call(conn, _default) do
    case CurrentPhoenixToken.verify_token(get_session(conn, :current_token), :current) do
      {:ok, :verify_token, :current, _current_token_info} ->

        conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "شما از قبل وارد سایت شده اید."))
        |> redirect(to: Routes.live_path(conn, MishkaHtmlWeb.HomeLive))
        |> halt()

      _ ->
        conn
    end
  end
end
