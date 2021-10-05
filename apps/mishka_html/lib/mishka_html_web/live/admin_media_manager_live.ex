defmodule MishkaHtmlWeb.AdminMediaManagerLive do
  use MishkaHtmlWeb, :live_view

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.BlogLink,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminMediaManagerView, "admin_media_manager_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    {:ok, assign(socket, user_id: Map.get(session, "user_id"), page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت فایل ها"), body_color: "#a29ac3cf")}
  end

  selected_menue("MishkaHtmlWeb.AdminMediaManagerLive")
end
