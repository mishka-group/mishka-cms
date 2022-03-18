defmodule MishkaHtmlWeb.AdminActivitiesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Activity
  @section_title MishkaTranslator.Gettext.dgettext("html_live",  "مدیریت فعالیت ها کاربری و لاگ سیستمی")

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.General.Activity,
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
        list={@activities}
        url={MishkaHtmlWeb.AdminActivitiesLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, AdminMenu, id: :admin_menu)}
        left_header_side=""
      />
    """
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
      page_title: @section_title,
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

  def section_fields() do
    [
      ListItemComponent.time_field("inserted_at", [1], "col header1", MishkaTranslator.Gettext.dgettext("html_live",  "تاریخ ثبت"), true,
      {true, false, false}),
      ListItemComponent.select_field("section", [1], "col header2", MishkaTranslator.Gettext.dgettext("html_live",  "بخش"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "مطلب بلاگ"), "blog_post"},
        {MishkaTranslator.Gettext.dgettext("html_live", "مجموعه بلاگ"), "blog_category"},
        {MishkaTranslator.Gettext.dgettext("html_live", "نظرات"), "comment"},
        {MishkaTranslator.Gettext.dgettext("html_live", "برچسب ها"), "tag"},
        {MishkaTranslator.Gettext.dgettext("html_live", "نویسندگان"), "blog_author"},
        {MishkaTranslator.Gettext.dgettext("html_live", "پست مطلب"), "blog_post_like"},
        {MishkaTranslator.Gettext.dgettext("html_live", "اتصال: برچسب بلاک"), "blog_tag_mapper"},
        {MishkaTranslator.Gettext.dgettext("html_live", "لینک بلاگ"), "blog_link"},
        {MishkaTranslator.Gettext.dgettext("html_live", "برچسب بلاگ"), "blog_tag"},
        {MishkaTranslator.Gettext.dgettext("html_live", "فعالیت ها"), "activity"},
        {MishkaTranslator.Gettext.dgettext("html_live", "بوکمارک"), "bookmark"},
        {MishkaTranslator.Gettext.dgettext("html_live", "پسند نظر"), "comment_like"},
        {MishkaTranslator.Gettext.dgettext("html_live", "اطلاع رسانی"), "notif"},
        {MishkaTranslator.Gettext.dgettext("html_live", "اشتراک ها"), "subscription"},
        {MishkaTranslator.Gettext.dgettext("html_live", "تنظیمات"), "setting"},
        {MishkaTranslator.Gettext.dgettext("html_live", "دسترسی ها"), "permission"},
        {MishkaTranslator.Gettext.dgettext("html_live", "نقش کاربری"), "role"},
        {MishkaTranslator.Gettext.dgettext("html_live", "اتصال: نقش کاربری"), "user_role"},
        {MishkaTranslator.Gettext.dgettext("html_live", "شناسه کاربر"), "identity"},
        {MishkaTranslator.Gettext.dgettext("html_live", "کاربر"), "user"},
        {MishkaTranslator.Gettext.dgettext("html_live", "دیگر"), "other"},
      ],
      {true, true, true}),
      ListItemComponent.select_field("priority", [1, 4], "col header3", MishkaTranslator.Gettext.dgettext("html_live",  "اولویت"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "ندارد"), "none"},
        {MishkaTranslator.Gettext.dgettext("html_live", "پایین"), "low"},
        {MishkaTranslator.Gettext.dgettext("html_live", "متوسط"), "medium"},
        {MishkaTranslator.Gettext.dgettext("html_live", "بالا"), "high"},
        {MishkaTranslator.Gettext.dgettext("html_live", "ویژه"), "featured"},
      ],
      {true, true, true}),
      ListItemComponent.select_field("status", [1, 4], "col header4", MishkaTranslator.Gettext.dgettext("html_live",  "وضعیت"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "خطا"), "error"},
        {MishkaTranslator.Gettext.dgettext("html_live", "اطلاعات"), "info"},
        {MishkaTranslator.Gettext.dgettext("html_live", "هشدار"), "warning"},
        {MishkaTranslator.Gettext.dgettext("html_live", "گزارش"), "report"},
        {MishkaTranslator.Gettext.dgettext("html_live", "throw"), "throw"},
        {MishkaTranslator.Gettext.dgettext("html_live", "خروج کامل"), "exit"},
      ],
      {true, true, true}),
      ListItemComponent.select_field("action", [1, 4], "col header5", MishkaTranslator.Gettext.dgettext("html_live",  "اکشن"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "اضافه کردن"), "add"},
        {MishkaTranslator.Gettext.dgettext("html_live", "ویرایش"), "edit"},
        {MishkaTranslator.Gettext.dgettext("html_live", "حذف با پرچم"), "delete"},
        {MishkaTranslator.Gettext.dgettext("html_live", "نابود کردن"), "destroy"},
        {MishkaTranslator.Gettext.dgettext("html_live", "خواندن"), "read"},
        {MishkaTranslator.Gettext.dgettext("html_live", "ارسال درخواست"), "send_request"},
        {MishkaTranslator.Gettext.dgettext("html_live", "دریافت درخواست"), "receive_request"},
        {MishkaTranslator.Gettext.dgettext("html_live", "احراز هویت"), "auth"},
        {MishkaTranslator.Gettext.dgettext("html_live", "دیگر"), "other"},
      ],
      {true, true, true}),
      ListItemComponent.select_field("type", [1, 4], "col header6", MishkaTranslator.Gettext.dgettext("html_live",  "نوع"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "بخش"), "section"},
        {MishkaTranslator.Gettext.dgettext("html_live", "ایمیل"), "email"},
        {MishkaTranslator.Gettext.dgettext("html_live", "API داخلی"), "internal_api"},
        {MishkaTranslator.Gettext.dgettext("html_live", "API خارجی"), "external_api"},
        {MishkaTranslator.Gettext.dgettext("html_live", "وب سایت"), "html_router"},
        {MishkaTranslator.Gettext.dgettext("html_live", "روتر API"), "api_router"},
        {MishkaTranslator.Gettext.dgettext("html_live", "بانک اطلاعاتی"), "db"},
        {MishkaTranslator.Gettext.dgettext("html_live", "مدیریت پلاگین"), "plugin"},
      ],
      {true, true, true})
    ]
  end

  def section_info(assigns, socket) do
    %{
      section_btns: %{
        header: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "آمار و گزارش ها"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostLive),
            class: "btn btn-outline-danger"
          },
        ],
        list_item: [
          %{
            method: :delete,
            router: nil,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "حذف"),
            class: "btn btn-outline-primary vazir"
          },
          %{
            method: :redirect,
            router: MishkaHtmlWeb.AdminActivityLive,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "مشاهده"),
            class: "btn btn-outline-success vazir",
            action: :id
          }
        ]
      },
      title: @section_title,
      description:
      ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "شما در این بخش می توانید فعالیت های مهم کاربری و همینطور لاگ های سیستمی از جمله ارور ها ناخواسته یا موارد امنیتی را مدیریت و مانیتور نمایید.") %>
        <br>
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "لطفا از حذف لاگ خوداری فرمایید. در صورت حذف لاگ بلافاصله فعالیت حذف نیز ذخیره سیستم می شود.") %>
      """
    }
  end
end
