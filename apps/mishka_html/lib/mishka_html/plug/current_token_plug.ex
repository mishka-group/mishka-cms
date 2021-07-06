defmodule MishkaHtml.Plug.CurrentTokenPlug do
  import Plug.Conn
  use MishkaHtmlWeb, :controller
  alias MishkaUser.Token.CurrentPhoenixToken

  alias MishkaHtmlWeb.Router.Helpers, as: Routes
  def init(default), do: default

  def call(conn, _default) do
    case CurrentPhoenixToken.verify_token(get_session(conn, :current_token), :current) do
      {:ok, :verify_token, :current, _current_token_info} ->
        conn
      _ ->
        conn
        |> fetch_session
        |> delete_session(:current_token)
        |> delete_session(:user_id)
        |> delete_session(:live_socket_id)
        |> put_flash(:error, "برای دسترسی به این صفحه لطفا وارد سایت شوید")
        |> redirect(to: Routes.auth_path(conn, :login))
        |> halt()
    end
  end
end
