defmodule MishkaHtmlWeb.AdminSeoLive do
  use MishkaHtmlWeb, :live_view


  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminSeoView, "admin_seo_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :menu, 100)
    {:ok, assign(socket, page_title: MishkaTranslator.Gettext.dgettext("html_live", "تنظیمات سئو"), body_color: "#a29ac3cf")}
  end

  @impl true
  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminSeoLive"})
    {:noreply, socket}
  end
end
