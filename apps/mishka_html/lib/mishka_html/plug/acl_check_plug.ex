defmodule MishkaHtml.Plug.AclCheckPlug do
  import Plug.Conn
  use MishkaHtmlWeb, :controller
  require MishkaTranslator.Gettext
  alias MishkaHtmlWeb.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _default) do
    user_ip = to_string(:inet_parse.ntoa(conn.remote_ip))
    with {:acl_check, false, action} <- {:acl_check, is_nil(get_acl_by_module_path(conn)), get_acl_by_module_path(conn)},
         {:user_id_check, false, user_id} <- {:user_id_check, is_nil(get_session(conn, :user_id)), get_session(conn, :user_id)},
         {:permittes?, true} <- {:permittes?, MishkaUser.Acl.Access.permittes?(action, user_id)} do

          on_user_authorisation(conn, get_session(conn, :user_id), user_ip).conn
    else
      {:acl_check, true, nil} -> on_user_authorisation(conn, get_session(conn, :user_id), user_ip).conn

      {:user_id_check, true, nil} ->
        on_user_authorisation_failure(conn, user_ip, {:user_id_check, true, nil}).conn
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "شما به این صفحه دسترسی ندارید یا ممکن است دسترسی شما ویرایش شده باشد. دوباره وارد سایت شوید."))
        |> redirect(to: Routes.live_path(conn, MishkaHtmlWeb.HomeLive))
        |> halt()

      {:permittes?, false} ->
        on_user_authorisation_failure(conn, user_ip, {:permittes?, false}).conn
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

  defp on_user_authorisation_failure(conn, user_ip, error, extra \\ []) do
    state = %MishkaInstaller.Reference.OnUserAuthorisationFailure{
      conn: conn, ip: user_ip, endpoint: :html, error: error, module: __MODULE__, operation: :call, extra: extra
    }
    MishkaInstaller.Hook.call(event: "on_user_authorisation_failure", state: state)
  end

  defp on_user_authorisation(conn, user_id, user_ip, extra \\ []) do
    state = %MishkaInstaller.Reference.OnUserAuthorisation{
      conn: conn, user_id: user_id, ip: user_ip, endpoint: :html, module: __MODULE__, operation: :call, extra: extra
    }
    MishkaInstaller.Hook.call(event: "on_user_authorisation", state: state)
  end
end
