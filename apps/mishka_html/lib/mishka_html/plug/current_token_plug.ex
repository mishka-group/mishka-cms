defmodule MishkaHtml.Plug.CurrentTokenPlug do
  import Plug.Conn
  use MishkaHtmlWeb, :controller
  alias MishkaUser.Token.CurrentPhoenixToken

  alias MishkaHtmlWeb.Router.Helpers, as: Routes
  def init(default), do: default

  def call(conn, _default) do
    with {:ok, :sesion_check, current_token} <- sesion_check(conn, :current_token),
         {:ok, :verify_token, :current, current_token_info} <- CurrentPhoenixToken.verify_token(current_token, :current) do
      conn
      |> assign(:current_token, current_token_info["token"])
      |> assign(:user_id, current_token_info["id"])

    else
      _ ->
      conn
      |> put_flash(:error, "برای دسترسی به این صفحه لطفا وارد سایت شوید")
      |> redirect(to: Routes.auth_path(conn, :login))
      |> halt()
    end
  end

  @spec sesion_check(Plug.Conn.t(), atom | binary) ::
          {:error, :sesion_check} | {:ok, :sesion_check, any}
  def sesion_check(conn, key) do
    case get_session(conn, key) do
      nil -> {:error, :sesion_check}
      session -> {:ok, :sesion_check, session}
    end
  end
end
