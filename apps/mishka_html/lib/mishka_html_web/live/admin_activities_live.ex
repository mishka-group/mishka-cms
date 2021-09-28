defmodule MishkaHtmlWeb.AdminActivitiesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Activity
  alias MishkaHtmlWeb.Admin.Activity.DeleteErrorComponent

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.General.Activity,
      redirect: __MODULE__,
      router: Routes


  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminActivityView, "admin_activities_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Activity.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
      page_size: 10,
      filters: %{},
      page: 1,
      open_modal: false,
      component: nil,
      user_id: Map.get(session, "user_id"),
      page_title: MishkaTranslator.Gettext.dgettext("html_live",  "مدیریت فعالیت ها کاربری و لاگ سیستمی"),
      body_color: "#a29ac3cf",
      activities: Activity.activities(conditions: {1, 10}, filters: %{})
    )

    {:ok, socket, temporary_assigns: [activities: []]}
  end

  # Live CRUD and Paginate
  paginate(:activities, user_id: false)

  list_search_and_action()

  delete_list_item(:activities, DeleteErrorComponent, false)

  selected_menue("MishkaHtmlWeb.AdminLogsLive")

  update_list(:activities, false)
end
