defmodule MishkaHtmlWeb.AdminSubscriptionsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Subscription
  @section_title MishkaTranslator.Gettext.dgettext("html_live", "مدیریت اشتراک ها")

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.General.Subscription,
      redirect: __MODULE__,
      router: Routes,
      skip_list: ["full_name"]


  @impl true
  def render(assigns) do
    ~H"""
      <.live_component
        module={MishkaHtml.Helpers.ListContainerComponent}
        id={:list_container}
        flash={@flash}
        section_info={section_info(assigns, @socket)}
        filters={@filters}
        list={@subscriptions}
        url={MishkaHtmlWeb.AdminSubscriptionsLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, AdminMenu, id: :admin_menu)}
        left_header_side=""
      />
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Subscription.subscribe()
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
        subscriptions: Subscription.subscriptions(conditions: {1, 10}, filters: %{})
      )

      {:ok, socket, temporary_assigns: [subscriptions: []]}
  end

  # Live CRUD
  paginate(:subscriptions, user_id: false)

  list_search_and_action()

  delete_list_item(:subscriptions, DeleteErrorComponent, false)

  selected_menue("MishkaHtmlWeb.AdminSubscriptionsLive")

  update_list(:subscriptions, false)

  def section_fields() do
    [
      ListItemComponent.select_field("section", [1, 4], "col header1", MishkaTranslator.Gettext.dgettext("html_live_component", "بخش"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "مطلب بلاگ"), "blog_post"},
        {MishkaTranslator.Gettext.dgettext("html_live", "مجموعه بلاگ"), "blog_category"}
      ],
      {true, true, true}),
      ListItemComponent.select_field("status", [1, 4], "col header2", MishkaTranslator.Gettext.dgettext("html_live",  "وضعیت"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "غیر فعال"), "inactive"},
        {MishkaTranslator.Gettext.dgettext("html_live", "فعال"), "active"},
        {MishkaTranslator.Gettext.dgettext("html_live", "آرشیو شده"), "archived"},
        {MishkaTranslator.Gettext.dgettext("html_live", "حذف با پرچم"), "soft_delete"},
      ],
      {true, true, true}),
      ListItemComponent.text_field("full_name", [1], "col header3", MishkaTranslator.Gettext.dgettext("html_live",  "کاربر"),
      {false, false, true}),
      ListItemComponent.text_field("user_full_name", [1], "col header4", MishkaTranslator.Gettext.dgettext("html_live",  "کاربر"),
      {true, false, false}),
      ListItemComponent.text_field("section_id", [1], "col header5", MishkaTranslator.Gettext.dgettext("html_live",  "شناسه بخش"),
      {false, true, true}),
      ListItemComponent.time_field("inserted_at", [1], "col header3", MishkaTranslator.Gettext.dgettext("html_live",  "تاریخ ثبت"), false,
      {true, false, false}),
      ListItemComponent.time_field("expire_time", [1], "col header4", MishkaTranslator.Gettext.dgettext("html_live",  "تاریخ انقضا"), false,
      {true, false, false})
    ]
  end
  def section_info(assigns, socket) do
    %{
      section_btns: %{
        header: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "ساخت اشتراک"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminSubscriptionLive),
            class: "btn btn-outline-danger"
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "آمار و گزارش ها"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive),
            class: "btn btn-outline-info"
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
            method: :redirect_key,
            router: MishkaHtmlWeb.AdminSubscriptionLive,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "ویرایش"),
            class: "btn btn-outline-danger vazir",
            action: :id,
            key: :id
          }
        ]
      },
      title: @section_title,
      activities_info: %{
        title: MishkaTranslator.Gettext.dgettext("html_live_templates", "اشتراک ها"),
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "اشتراک"),
        action: :user_full_name,
        action_by: :user_full_name,
      },
      custom_operations: nil,
      description:
      ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "شما در این بخش می توانید اشتراک های کاربران را مدیریت نمایید.") %>
        <div class="space30"></div>
      """
    }
  end
end
