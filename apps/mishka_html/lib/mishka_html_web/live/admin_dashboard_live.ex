defmodule MishkaHtmlWeb.AdminDashboardLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, _session, socket) do
    Process.send_after(self(), :menu, 10)
    {:ok, assign(socket, page_title: "داشبورد مدیریت", body_color: "#a29ac3cf")}
  end

  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminDashboardLive"})
    {:noreply, socket}
  end
end
