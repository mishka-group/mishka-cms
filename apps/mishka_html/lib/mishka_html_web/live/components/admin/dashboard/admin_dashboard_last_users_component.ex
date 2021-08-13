defmodule MishkaHtmlWeb.Admin.Dashboard.LastUsersComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    # MishkaHtml.full_name_sanitize(user_full_name)
    ~L"""
      <div class="col admin-home-toos-right vazir">
        <h3>
        <div class="row">
          <span class="col-sm-1 iconly-bulkChat">
            <span class="path1"></span><span class="path2"></span>
          </span>
          <span class="col admin-home-last-comment-title rtl">آخرین ثبت نام ها</span>
        </div>
        </h3>
        <div class="space20"></div>
          <ul class="admin-home-ul-of-lists vazir">
            <li>شهریار توکلی</li>
            <li>آرین علیجانی</li>
            <li>مجتبی ناصری</li>
            <li>شقایق توکلی</li>
          </ul>



      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
