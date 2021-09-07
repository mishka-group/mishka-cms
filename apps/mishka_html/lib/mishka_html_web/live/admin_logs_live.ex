defmodule MishkaHtmlWeb.AdminLogsLive do
  use MishkaHtmlWeb, :live_view

  # TODO: change module
  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.BlogLink,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminLogView, "admin_logs_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :menu, 100)
    {:ok, assign(socket, page_title: MishkaTranslator.Gettext.dgettext("html_live",  "مدیریت لاگ ها"), body_color: "#a29ac3cf")}
  end

  selected_menue("MishkaHtmlWeb.AdminLogsLive")
end
