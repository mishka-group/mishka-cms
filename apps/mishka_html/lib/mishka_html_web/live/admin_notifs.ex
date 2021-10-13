defmodule MishkaHtmlWeb.AdminBlogNotifsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Notif
  alias MishkaHtmlWeb.Admin.Notif.DeleteErrorComponent

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.General.Notif,
      redirect: __MODULE__,
      router: Routes


  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminNotifView, "admin_notifs_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Notif.subscribe()
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
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت اعلانات"),
        notifs: Notif.notifs(conditions: {1, 10}, filters: %{}),
      )
    {:ok, socket, temporary_assigns: [categories: []]}
  end

  # Live CRUD and Paginate
  paginate(:notifs, user_id: false)

  list_search_and_action()

  delete_list_item(:notifs, DeleteErrorComponent, false)

  selected_menue("MishkaHtmlWeb.AdminBlogNotifsLive")

  update_list(:notifs, false)
end
