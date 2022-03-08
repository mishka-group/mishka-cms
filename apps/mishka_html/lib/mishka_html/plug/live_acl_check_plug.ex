defmodule MishkaHtml.Plug.LiveAclCheckPlug do
  import Phoenix.LiveView
  require MishkaTranslator.Gettext
  alias MishkaHtmlWeb.Router.Helpers, as: Routes

  def on_mount(_section, _params, session, socket) do
    user_ip = get_connect_info(socket, :peer_data).address
    with {:acl_check, false, action} <- {:acl_check, is_nil(get_acl_by_module_path(socket)), get_acl_by_module_path(socket)},
         {:user_id_check, false, user_id} <- {:user_id_check, is_nil(Map.get(session, "user_id")), Map.get(session, "user_id")},
         {:permittes?, true} <- {:permittes?, MishkaUser.Acl.Access.permittes?(action, user_id)} do

          {:cont, on_user_authorisation(socket, Map.get(session, "user_id"), user_ip).conn}
    else
      {:acl_check, true, nil} -> {:cont, on_user_authorisation(socket, Map.get(session, "user_id"), user_ip).conn}

      {:user_id_check, true, nil} ->
        socket =
          on_user_authorisation_failure(socket, user_ip, {:user_id_check, true, nil}).conn
          |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "شما به این صفحه دسترسی ندارید یا ممکن است دسترسی شما ویرایش شده باشد. دوباره وارد سایت شوید."))
          |> redirect(to: Routes.live_path(socket, MishkaHtmlWeb.HomeLive))

        {:halt, socket}

      {:permittes?, false} ->
        socket =
          on_user_authorisation_failure(socket, user_ip, {:permittes?, false}).conn
          |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "شما به این صفحه دسترسی ندارید یا ممکن است دسترسی شما ویرایش شده باشد. دوباره وارد سایت شوید."))
          |> redirect(to: Routes.live_path(socket, MishkaHtmlWeb.HomeLive))

        {:halt, socket}
    end
  end

  defp get_acl_by_module_path(conn) do
    module = Map.get(conn.private, :root_view) || "NotFound"
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
