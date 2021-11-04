defmodule MishkaHtmlWeb.Admin.Dashboard.LastUsersComponent do
  use MishkaHtmlWeb, :live_component


  def render(assigns) do
    ~L"""
      <div class="col admin-home-toos-right vazir">
        <h3>
        <div class="row">
          <span class="col-sm-1 iconly-bulkChat">
            <span class="path1"></span><span class="path2"></span>
          </span>
          <span class="col admin-home-last-comment-title rtl"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "آخرین ثبت نام ها") %></span>
        </div>
        </h3>
        <div class="space20"></div>
          <ul class="admin-home-ul-of-lists vazir">
            <%= for user <- @users.entries do %>
              <li><%= MishkaHtml.full_name_sanitize(user.full_name) %></li>
            <% end %>
          </ul>
          <div class="space20"></div>
          <%= live_redirect MishkaTranslator.Gettext.dgettext("html_live_templates", "نمایش همه کاربران"), to: Routes.live_path(@socket, MishkaHtmlWeb.AdminUsersLive), class: "col-sm-12 btn btn-outline-secondary btn-lg" %>
      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
