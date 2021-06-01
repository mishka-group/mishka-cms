defmodule MishkaHtmlWeb.Admin.Dashboard.LastBlogPostsComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="container rtl">
        <div class="clearfix"></div>
        <h3 class="admin-home-calendar-h3-title-last-post">آخرین به روز رسانی:</h3>

        <div class="row">
          <div class="col ttt test1"></div>
          <div class="col-sm-1"></div>
          <div class="col ttt test2"></div>
          <div class="col-sm-1"></div>
          <div class="col ttt test3"></div>
        </div>

        <div class="clearfix"></div>
      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
