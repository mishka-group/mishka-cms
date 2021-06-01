defmodule MishkaHtmlWeb.Admin.Public.MenuComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <nav class="col navbar">
        <div class="row">

          <div class="col-lg-1 admin-home-quickmenu-navbar-brand" href="#">
            <span class="iconly-bulkCategory">
              <span class="path1"></span><span class="path2"></span>
            </span>
          </div>

          <div class="col admin-home-quickmenu-top-menu rtl">
            <a class="col" phx-click="dashboard" phx-target="<%= @myself %>">داشبورد</a>
            <a class="col" phx-click="media-manager" phx-target="<%= @myself %>">مدیریت فایل</a>
          </div>


          <%= live_component @socket, MishkaHtmlWeb.Admin.Public.SearchComponent, id: :admin_search %>

        </div>
      </nav>
    """
  end

  def handle_event("dashboard", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, MishkaHtmlWeb.AdminDashboardLive))}
  end

  def handle_event("media-manager", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, MishkaHtmlWeb.AdminCommentsLive))}
  end
end
