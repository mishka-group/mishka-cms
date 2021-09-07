defmodule MishkaHtmlWeb.AdminLogLive do
  use MishkaHtmlWeb, :live_view

  # TODO: change module
  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.BlogLink,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminLogView, "admin_log_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :menu, 100)
    {:ok, assign(socket, body_color: "#a29ac3cf")}
  end

  selected_menue("MishkaHtmlWeb.AdminLogLive")
end
