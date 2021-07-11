defmodule MishkaHtmlWeb.HomeLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 500)
    socket =
      assign(socket,
        page_title: "تگرگ",
        body_color: "#40485d",
        user_id: Map.get(session, "user_id")
      )
    {:ok, socket}
  end

  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "home"})
    {:noreply, socket}
  end
end
