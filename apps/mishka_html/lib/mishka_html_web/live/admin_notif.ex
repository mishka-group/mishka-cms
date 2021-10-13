defmodule MishkaHtmlWeb.AdminBlogNotifLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Notif

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.General.Notif,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminNotifView, "admin_notif_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        user_id: Map.get(session, "user_id"),
        body_color: "#a29ac3cf",
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت اعلانات")
      )
    {:ok, socket, temporary_assigns: [categories: []]}
  end

  selected_menue("MishkaHtmlWeb.AdminBlogNotifLive")
end
