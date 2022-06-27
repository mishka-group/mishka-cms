defmodule MishkaHtml.Plug.CurrentTokenPlug do
  import Plug.Conn
  use MishkaHtmlWeb, :controller
  alias MishkaUser.Token.CurrentPhoenixToken
  require MishkaTranslator.Gettext
  alias MishkaHtmlWeb.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _default) do
    user_ip = to_string(:inet_parse.ntoa(conn.remote_ip))

    case CurrentPhoenixToken.verify_token(get_session(conn, :current_token), :current) do
      {:ok, :verify_token, :current, _current_token_info} ->
        on_user_authorisation(conn, get_session(conn, :user_id), user_ip).conn

      error ->
        on_user_authorisation_failure(conn, user_ip, error).conn
        |> fetch_session
        |> delete_session(:current_token)
        |> delete_session(:user_id)
        |> delete_session(:live_socket_id)
        |> put_flash(
          :error,
          MishkaTranslator.Gettext.dgettext(
            "html_auth",
            "برای دسترسی به این صفحه لطفا وارد سایت شوید"
          )
        )
        |> redirect(to: Routes.auth_path(conn, :login))
        |> halt()
    end
  end

  defp on_user_authorisation_failure(conn, user_ip, error, extra \\ []) do
    state = %MishkaInstaller.Reference.OnUserAuthorisationFailure{
      conn: conn,
      ip: user_ip,
      endpoint: :html,
      error: error,
      module: __MODULE__,
      operation: :call,
      extra: extra
    }

    MishkaInstaller.Hook.call(event: "on_user_authorisation_failure", state: state)
  end

  defp on_user_authorisation(conn, user_id, user_ip, extra \\ []) do
    state = %MishkaInstaller.Reference.OnUserAuthorisation{
      conn: conn,
      user_id: user_id,
      ip: user_ip,
      endpoint: :html,
      module: __MODULE__,
      operation: :call,
      extra: extra
    }

    MishkaInstaller.Hook.call(event: "on_user_authorisation", state: state)
  end
end
