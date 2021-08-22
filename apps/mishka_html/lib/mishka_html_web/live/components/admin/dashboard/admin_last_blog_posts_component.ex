defmodule MishkaHtmlWeb.Admin.Dashboard.LastBlogPostsComponent do
  use MishkaHtmlWeb, :live_component


  def render(assigns) do
    ~L"""
      <div class="container rtl">
        <div class="clearfix"></div>
        <h3 class="admin-home-calendar-h3-title-last-post"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "آخرین مطالب منتشر شده:") %></h3>

        <div class="row">
          <%= for post <- @posts do %>
            <div class="col last-admin-home-posts">
              <%= live_redirect to: Routes.live_path(@socket, MishkaHtmlWeb.AdminBlogPostLive, id: post.id), replace: false do %>
              <img class="img-fluid admin-home-blog-post-img" src="<%= post.main_image %>" alt="<%= post.title %>">
              <% end %>
            </div>
          <% end %>
        </div>

        <div class="clearfix"></div>
      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
