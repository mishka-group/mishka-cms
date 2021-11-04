defmodule MishkaHtml.Plug.AclCheckPlug do
  import Plug.Conn
  use MishkaHtmlWeb, :controller
  require MishkaTranslator.Gettext
  alias MishkaHtmlWeb.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _default) do
    with {:acl_check, false, action} <- {:acl_check, is_nil(get_acl_by_module_path(conn)), get_acl_by_module_path(conn)},
         {:user_id_check, false, user_id} <- {:user_id_check, is_nil(get_session(conn, :user_id)), get_session(conn, :user_id)},
         {:permittes?, true} <- {:permittes?, MishkaUser.Acl.Access.permittes?(action, user_id)} do

          conn
    else
      {:acl_check, true, nil} -> conn

      {:user_id_check, true, nil} ->
        conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "شما به این صفحه دسترسی ندارید یا ممکن است دسترسی شما ویرایش شده باشد. دوباره وارد سایت شوید."))
        |> redirect(to: Routes.live_path(conn, MishkaHtmlWeb.HomeLive))
        |> halt()

      {:permittes?, false} ->
        conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "شما به این صفحه دسترسی ندارید یا ممکن است دسترسی شما ویرایش شده باشد. دوباره وارد سایت شوید."))
        |> redirect(to: Routes.live_path(conn, MishkaHtmlWeb.HomeLive))
        |> halt()
    end
  end

  defp get_acl_by_module_path(conn) do
    module = case Map.get(conn.private, :phoenix_live_view) do
      nil -> "NotFound"
      module -> module |> elem(0)
    end
    MishkaUser.Acl.Action.actions
    |> Map.get(module |> to_string() |> String.replace("Elixir.", ""))
  end
end
