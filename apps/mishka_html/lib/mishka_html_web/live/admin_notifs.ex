defmodule MishkaHtmlWeb.AdminBlogNotifsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Notif
  @section_title MishkaTranslator.Gettext.dgettext("html_live", "مدیریت اعلانات")

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.General.Notif,
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
        list={@notifs}
        url={MishkaHtmlWeb.AdminBlogNotifsLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, AdminMenu, id: :admin_menu)}
        left_header_side=""
      />
    """
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
        notifs: Notif.notifs(conditions: {1, 10}, filters: %{})
      )
    {:ok, socket, temporary_assigns: [categories: []]}
  end

  # Live CRUD and Paginate
  paginate(:notifs, user_id: false)

  list_search_and_action()

  delete_list_item(:notifs, DeleteErrorComponent, false)

  selected_menue("MishkaHtmlWeb.AdminBlogNotifsLive")

  update_list(:notifs, false)

  def section_fields() do
    [
      ListItemComponent.text_field("title", [1], "col-sm-3 header1", MishkaTranslator.Gettext.dgettext("html_live",  "تیتر اعلان"),
      {true, true, true}, &MishkaHtml.title_sanitize/1),
      ListItemComponent.select_field("status", [1, 4], "col header2", MishkaTranslator.Gettext.dgettext("html_live",  "وضعیت"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "غیر فعال"), "inactive"},
        {MishkaTranslator.Gettext.dgettext("html_live", "فعال"), "active"},
        {MishkaTranslator.Gettext.dgettext("html_live", "آرشیو شده"), "archived"},
        {MishkaTranslator.Gettext.dgettext("html_live", "حذف با پرچم"), "soft_delete"}
      ],
      {true, true, true}),
      ListItemComponent.select_field("section", [1, 4], "col header3", MishkaTranslator.Gettext.dgettext("html_live_component", "بخش"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "مطلب بلاگ"), "blog_post"},
        {MishkaTranslator.Gettext.dgettext("html_live", "مدیریت"), "admin"},
        {MishkaTranslator.Gettext.dgettext("html_live", "عمومی"), "public"},
        {MishkaTranslator.Gettext.dgettext("html_live", "کاربر خاص"), "user_only"}
      ],
      {true, true, true}),
      ListItemComponent.select_field("type", [1, 4], "col header4", MishkaTranslator.Gettext.dgettext("html_live_component", "نوع"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "کاربری"), "client"},
        {MishkaTranslator.Gettext.dgettext("html_live", "مدیریت"), "admin"}
      ],
      {true, true, true}),
      ListItemComponent.select_field("target", [1, 4], "col header5", MishkaTranslator.Gettext.dgettext("html_live_component", "هدف"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "همه"), "all"},
        {MishkaTranslator.Gettext.dgettext("html_live", "موبایل"), "mobile"},
        {MishkaTranslator.Gettext.dgettext("html_live", "اندروید"), "android"},
        {MishkaTranslator.Gettext.dgettext("html_live", "iOS"), "ios"},
        {MishkaTranslator.Gettext.dgettext("html_live", "cli"), "cli"}
      ],
      {true, true, true}),
      ListItemComponent.link_field("full_name", [1], "col header1", MishkaTranslator.Gettext.dgettext("html_live",  "کاربر"),
      {MishkaHtmlWeb.AdminUserLive, :user_id},
      {true, false, false}, &MishkaHtml.full_name_sanitize/1),
      ListItemComponent.time_field("inserted_at", [1], "col header7", MishkaTranslator.Gettext.dgettext("html_live",  "ثبت"), false,
      {true, false, false})
    ]
  end

  def section_info(assigns, socket) do
    %{
      section_btns: %{
        header: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "ارسال اعلان"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogNotifLive),
            class: "btn btn-outline-danger"
          }
        ],
        list_item: [
          %{
            method: :delete,
            router: nil,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "حذف"),
            class: "btn btn-outline-primary vazir"
          },
          %{
            method: :redirect_keys,
            router: MishkaHtmlWeb.AdminBlogNotifLive,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "ویرایش"),
            class: "btn btn-outline-danger vazir",
            keys: [
              {:id, :id},
              {:type, "edit"},
            ]
          },
          %{
            method: :redirect_keys,
            router: MishkaHtmlWeb.AdminBlogNotifLive,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "نمایش"),
            class: "btn btn-outline-info vazir",
            keys: [
              {:id, :id},
              {:type, "show"},
            ]
          }
        ]
      },
      title: @section_title,
      activities_info: %{
        title: MishkaTranslator.Gettext.dgettext("html_live_templates", "اعلانات"),
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "اعلان"),
        action: :section,
        action_by: :section,
      },
      custom_operations: nil,
      description:
      ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "شما در این بخش می توانید اعلانات ارسال شده چه به وسیله سیستم و چه به وسیله مدیریت که به صورت انبوه ارسال می شود را مدیریت کنید.") %>
        <div class="space30"></div>
      """
    }
  end
end
