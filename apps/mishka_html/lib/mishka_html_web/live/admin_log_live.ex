defmodule MishkaHtmlWeb.AdminLogLive do
  use MishkaHtmlWeb, :live_view

  def mount(_params, _session, socket) do
    Process.send_after(self(), :menu, 100)
    {:ok, assign(socket, body_color: "#a29ac3cf")}
  end

  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminLogLive"})
    {:noreply, socket}
  end
end
