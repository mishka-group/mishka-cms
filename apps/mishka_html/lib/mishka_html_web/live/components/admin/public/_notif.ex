defmodule MishkaHtmlWeb.Admin.Public.Notif do
  use MishkaHtmlWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: subscribe()
    {:ok, assign(socket, notifs: [])}
  end

  def render(assigns) do
    ~H"""
      <div class="toast-container" id="admin_notif">
        <%= for notif <- @notifs do %>
          <div class="admin-notif-live p-3 vazir rtl" style="z-index: 5">
            <div id="liveToast" class="toast show" role="alert" aria-live="assertive" aria-atomic="true">
              <div class="toast-header">
                <svg class="bd-placeholder-img rounded me-2" width="20" height="20" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" preserveAspectRatio="xMidYMid slice" focusable="false">
                  <rect width="100%" height="100%" fill="#007aff"></rect>
                </svg>
                <strong class="admin-notif-live-title"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "اطلاع رسانی") %></strong>
                <div class="clearfix"></div>
                <div class="col space10"> </div>
                <small><%= MishkaTranslator.Gettext.dgettext("html_live_component", "یک دقیقه پیش") %></small>
                <button phx-click="close" phx-value-id={notif.id} type="button" class="me-auto btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
              </div>
              <div class="admin-notif-live-text toast-body vazir">
                <%= notif.msg %>
              </div>
            </div>
          </div>
          <div class="clearfix"></div>
          <div class="col space10"> </div>
        <% end %>
      </div>
    """
  end

  def handle_event("close", %{"id" => id}, socket) do
    {:noreply, assign(socket, notifs: drop_notif(socket, id))}
  end

  def handle_info({:add_notif, info}, socket) do
    notifs = [info | socket.assigns.notifs]
    {:noreply, assign(socket, notifs: notifs)}
  end

  defp drop_notif(socket, id) do
    Enum.reject(socket.assigns.notifs, fn x -> x.id == id end)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "admin_notif")
  end

  def notify_subscribers(notif) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "admin_notif", {:add_notif, notif})
  end
end
