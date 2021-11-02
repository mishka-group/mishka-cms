defmodule MishkaHtml.Plug.LiveAclCheckPlug do
  import Phoenix.LiveView
  require MishkaTranslator.Gettext
  alias MishkaHtmlWeb.Router.Helpers, as: Routes

  def mount(_params, session, socket) do
    with {:acl_check, false, action} <- {:acl_check, is_nil(get_acl_by_module_path(socket)), get_acl_by_module_path(socket)},
         {:user_id_check, false, user_id} <- {:user_id_check, is_nil(Map.get(session, "user_id")), Map.get(session, "user_id")},
         {:permittes?, true} <- {:permittes?, MishkaUser.Acl.Access.permittes?(action, user_id)} do

          {:cont, socket}
    else
      {:acl_check, true, nil} -> {:cont, socket}

      {:user_id_check, true, nil} ->
        socket = socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "شما به این صفحه دسترسی ندارید یا ممکن است دسترسی شما ویرایش شده باشد. دوباره وارد سایت شوید."))
        |> redirect(to: Routes.live_path(socket, MishkaHtmlWeb.HomeLive))

        {:halt, socket}

      {:permittes?, false} ->
        socket = socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_auth", "شما به این صفحه دسترسی ندارید یا ممکن است دسترسی شما ویرایش شده باشد. دوباره وارد سایت شوید."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.BlogsLive))

        {:halt, socket}

    end
  end

  defp get_acl_by_module_path(conn) do
    module = Map.get(conn.private, :root_view) || "NotFound"
    MishkaUser.Acl.Action.actions
    |> Map.get(module |> to_string() |> String.replace("Elixir.", ""))
  end
end
