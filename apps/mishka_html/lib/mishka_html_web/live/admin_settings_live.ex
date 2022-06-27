defmodule MishkaHtmlWeb.AdminSettingsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaInstaller.Setting
  @section_title MishkaTranslator.Gettext.dgettext("html_live", "تنظیمات")

  use MishkaHtml.Helpers.LiveCRUD,
    module: MishkaInstaller.Setting,
    redirect: __MODULE__,
    router: Routes

  @impl true
  def render(assigns) do
    ~H"""
      <.live_component
        module={MishkaHtml.Helpers.ListContainerComponent}
        id={:list_container}
        flash={@flash}
        section_info={section_info(assigns, @socket)}
        filters={@filters}
        list={@settings}
        url={MishkaHtmlWeb.AdminSettingsLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, AdminMenu, id: :admin_menu)}
        left_header_side=""
      />
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Setting.subscribe()
    Process.send_after(self(), :menu, 100)

    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        user_id: Map.get(session, "user_id"),
        open_modal: false,
        component: nil,
        body_color: "#a29ac3cf",
        page_title: @section_title,
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

  def section_fields() do
    [
      ListItemComponent.text_field(
        "name",
        [1],
        "col header2",
        MishkaTranslator.Gettext.dgettext("html_live", "نام بخش"),
        {true, true, true},
        &MishkaHtml.title_sanitize/1
      ),
      ListItemComponent.time_field(
        "updated_at",
        [1],
        "col header5",
        MishkaTranslator.Gettext.dgettext("html_live", "به روز رسانی"),
        false,
        {true, false, false}
      ),
      ListItemComponent.time_field(
        "inserted_at",
        [1],
        "col header1",
        MishkaTranslator.Gettext.dgettext("html_live", "ثبت"),
        false,
        {true, false, false}
      )
    ]
  end

  def section_info(assigns, socket) do
    %{
      section_btns: %{
        header: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "ساخت تنظیمات جدید"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminSettingLive),
            class: "btn btn-outline-danger"
          }
        ],
        list_item: [
          %{
            method: :delete,
            router: nil,
            title: MishkaTranslator.Gettext.dgettext("html_live", "حذف"),
            class: "btn btn-outline-primary vazir"
          },
          %{
            method: :redirect_key,
            router: MishkaHtmlWeb.AdminSettingLive,
            title: MishkaTranslator.Gettext.dgettext("html_live", "ویرایش"),
            class: "btn btn-outline-danger vazir",
            action: :id,
            key: :id
          }
        ]
      },
      title: @section_title,
      activities_info: %{
        title: MishkaTranslator.Gettext.dgettext("html_live_templates", "تنظیمات"),
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "تنظیمات"),
        action: :user_full_name,
        action_by: :user_full_name
      },
      custom_operations: nil,
      description: ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "شما در این بخش می توانید برای هر قسمت از سایت که از قبل معرفی شده است تنظیمات مورد نظر خود را وارد یا ویرایش کنید.") %>
        <div class="space30"></div>
      """
    }
  end
end
