defmodule MishkaHtmlWeb.Admin.Dashboard.LastNotifComponent do
  use MishkaHtmlWeb, :live_component

  def render(assigns) do
    ~L"""
      <div class="col admin-home-toos-left vazir">
        <h3>
          <div class="row">
            <span class="col-sm-1 iconly-bulkDanger"><span class="path1"></span><span class="path2"></span></span>

            <span class="col admin-home-last-notif-title rtl">آخرین خبررسانی های عمومی</span>
            <div class="space20"></div>
            <ul class="admin-home-ul-of-lists vazir">
              <li>اطلاع رسانی: به زودی ...</li>
              <li>اطلاع رسانی: به زودی ...</li>
              <li>اطلاع رسانی: به زودی ...</li>
              <li>اطلاع رسانی: به زودی ...</li>
            </ul>
          </div>


        </h3>
      </div>
    """
  end

  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
