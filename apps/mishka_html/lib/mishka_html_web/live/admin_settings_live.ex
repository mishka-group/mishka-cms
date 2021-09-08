defmodule MishkaHtmlWeb.AdminSettingsLive do
  use MishkaHtmlWeb, :live_view
  alias MishkaDatabase.Public.Setting
  alias MishkaHtmlWeb.Admin.Blog.Category.DeleteErrorComponent


  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaDatabase.Public.Setting,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminSettingView, "admin_settings_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Setting.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        body_color: "#a29ac3cf",
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "تنظیمات"),
        settings: Setting.settings(conditions: {1, 10}, filters: %{})
      )
    {:ok, socket, temporary_assigns: [settings: []]}
  end

  # Live CRUD
  paginate(:settings, user_id: false)

  list_search_and_action()

  delete_list_item(:settings, DeleteErrorComponent, false)

  selected_menue("MishkaHtmlWeb.AdminSettingsLive")

  update_list(:settings, false)

  @impl true
  def handle_info(_params, socket) do
    {:noreply, socket}
  end
end
