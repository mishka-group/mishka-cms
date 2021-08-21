defmodule MishkaHtmlWeb.Admin.Public.AdminMenu do
  use MishkaHtmlWeb, :live_view

  alias MishkaUser.Token.CurrentPhoenixToken
  def mount(_params, session, socket) do
    if connected?(socket), do: subscribe()
    Process.send_after(self(), :update, 10)
    socket =
      assign(socket,
        user_id: Map.get(session, "user_id"),
        current_token: Map.get(session, "current_token"),
        menu_name: nil
      )
    {:ok, socket}
   end

  def render(assigns) do
    ~L"""
      <nav class="col navbar admin-main-menu-top-block">
        <div class="row">

          <div class="col-lg-1 admin-home-quickmenu-navbar-brand" href="#">
            <span class="iconly-bulkCategory">
              <span class="path1"></span><span class="path2"></span>
            </span>
          </div>

          <div class="col admin-home-quickmenu-top-menu rtl">
            <%= live_redirect "داشبورد", to: Routes.live_path(@socket, MishkaHtmlWeb.AdminDashboardLive) %>
            <%= live_redirect "مدیریت فایل", to: Routes.live_path(@socket, MishkaHtmlWeb.AdminCommentsLive) %>
            <%= live_redirect "سایت", to: Routes.live_path(@socket, MishkaHtmlWeb.HomeLive) %>
          </div>

        </div>
      </nav>

      <div class="collapse" id="navbarToggleExternalContent">
        <div class="p-4">
          <div class="col admin-home-quickmenu-top-menu rtl">
            <%= live_redirect "داشبورد", to: Routes.live_path(@socket, MishkaHtmlWeb.AdminDashboardLive) %>
            <%= live_redirect "مدیریت فایل", to: Routes.live_path(@socket, MishkaHtmlWeb.AdminCommentsLive) %>
            <%= live_redirect "سایت", to: Routes.live_path(@socket, MishkaHtmlWeb.HomeLive) %>
          </div>
        </div>
      </div>

      <nav class="col-sm-3 navbar navbar-dark text-right mobile-admin-top-menu">
        <div class="container-fluid mobile-menu">
          <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarToggleExternalContent" aria-controls="navbarToggleExternalContent" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
          </button>
        </div>
      </nav>

    """
  end

  def handle_info({:menu, name}, socket) do
    {:noreply, assign(socket, :menu_name, name)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 10000)
    socket.assigns.current_token
    |> verify_token()
    |> acl_check(socket)
  end

  defp verify_token(nil), do: {:error, :verify_token, :no_token}

  defp verify_token(current_token) do
    case CurrentPhoenixToken.verify_token(current_token, :current) do
      {:ok, :verify_token, :current, current_token_info} -> {:ok, :verify_token, current_token_info["id"], current_token}

      _ -> {:error, :verify_token}
    end
  end

  defp acl_check({:error, :verify_token, :no_token}, socket), do: {:noreply, socket}

  defp acl_check({:error, :verify_token}, socket) do
    socket =
      socket
      |> redirect(to: Routes.auth_path(socket, :log_out))

    {:noreply, socket}
  end

  defp acl_check({:ok, :verify_token, user_id, current_token}, socket) do
    acl_got = Map.get(MishkaUser.Acl.Action.actions, socket.assigns.menu_name)

    socket =
      with {:acl_check, false, action} <- {:acl_check, is_nil(acl_got), acl_got},
         {:permittes?, true} <- {:permittes?, MishkaUser.Acl.Access.permittes?(action, user_id)} do

          socket
          |> assign(user_id: user_id, current_token: current_token)

      else
        {:acl_check, true, nil} ->

          socket
          |> assign(user_id: user_id, current_token: current_token)

        {:permittes?, false} ->

          socket
          |> put_flash(:warning, "شما به این صفحه دسترسی ندارید یا ممکن است دسترسی شما تغییر کرده باشد لطفا دوباره وارد سایت شوید.")
          |> redirect(to: Routes.live_path(socket, MishkaHtmlWeb.HomeLive))

      end

    {:noreply, socket}
  end

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "admin_menu")
  end

  def notify_subscribers(notif) when is_tuple(notif) do
     Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "admin_menu", notif)
  end
end
