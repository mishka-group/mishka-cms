defmodule MishkaHtmlWeb.AdminCommentsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Comment
  @section_title MishkaTranslator.Gettext.dgettext("html_live", "مدیریت نظرات")

  use MishkaHtml.Helpers.LiveCRUD,
    module: MishkaContent.General.Comment,
    redirect: __MODULE__,
    router: Routes

  @impl true
  def render(assigns) do
    IO.inspect(assigns.filters)

    ~H"""
      <.live_component
        module={MishkaHtml.Helpers.ListContainerComponent}
        id={:list_container}
        flash={@flash}
        section_info={section_info(assigns, @socket)}
        filters={@filters}
        list={@comments}
        url={MishkaHtmlWeb.AdminCommentsLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, AdminMenu, id: :admin_menu)}
        left_header_side=""
      />
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Comment.subscribe()
    Process.send_after(self(), :menu, 100)

    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        user_id: Map.get(session, "user_id"),
        component: nil,
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت نظرات"),
        body_color: "#a29ac3cf",
        comments: Comment.comments(conditions: {1, 10}, filters: %{}, user_id: nil)
      )

    {:ok, socket, temporary_assigns: [comments: []]}
  end

  # Live CRUD
  paginate(:comments, user_id: true)

  list_search_and_action()

  delete_list_item(:comments, DeleteErrorComponent, true)

  @impl true
  def handle_event("dependency", %{"id" => id}, socket) do
    socket =
      push_patch(socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            params:
              MishkaHtml.Helpers.LiveCRUD.paginate_assign_filter(
                Map.merge(socket.assigns.filters, %{"sub" => id}),
                Comment,
                nil
              ),
            count: socket.assigns.page_size
          )
      )

    {:noreply, socket}
  end

  selected_menue("MishkaHtmlWeb.AdminCommentsLive")

  update_list(:comments, true)

  def section_fields() do
    [
      ListItemComponent.select_field(
        "section",
        [1, 4],
        "col header1",
        MishkaTranslator.Gettext.dgettext("html_live_component", "بخش"),
        [
          {MishkaTranslator.Gettext.dgettext("html_live", "مطلب بلاگ"), "blog_post"}
        ],
        {true, true, true}
      ),
      ListItemComponent.select_field(
        "status",
        [1, 4],
        "col header2",
        MishkaTranslator.Gettext.dgettext("html_live", "وضعیت"),
        [
          {MishkaTranslator.Gettext.dgettext("html_live", "غیر فعال"), "inactive"},
          {MishkaTranslator.Gettext.dgettext("html_live", "فعال"), "active"},
          {MishkaTranslator.Gettext.dgettext("html_live", "آرشیو شده"), "archived"},
          {MishkaTranslator.Gettext.dgettext("html_live", "حذف با پرچم"), "soft_delete"}
        ],
        {true, true, true}
      ),
      ListItemComponent.select_field(
        "priority",
        [1, 4],
        "col header3",
        MishkaTranslator.Gettext.dgettext("html_live", "وضعیت"),
        [
          {MishkaTranslator.Gettext.dgettext("html_live", "ندارد"), "none"},
          {MishkaTranslator.Gettext.dgettext("html_live", "پایین"), "low"},
          {MishkaTranslator.Gettext.dgettext("html_live", "متوسط"), "medium"},
          {MishkaTranslator.Gettext.dgettext("html_live", "بالا"), "high"},
          {MishkaTranslator.Gettext.dgettext("html_live", "ویژه"), "featured"}
        ],
        {true, true, true}
      ),
      ListItemComponent.text_field(
        "user_full_name",
        [1],
        "col header4",
        MishkaTranslator.Gettext.dgettext("html_live", "کاربر"),
        {true, false, false},
        &MishkaHtml.full_name_sanitize/1
      ),
      ListItemComponent.time_field(
        "inserted_at",
        [1],
        "col header5",
        MishkaTranslator.Gettext.dgettext("html_live", "تاریخ ثبت"),
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
            title: MishkaTranslator.Gettext.dgettext("html_live", "حذف"),
            class: "btn btn-outline-primary vazir"
          },
          %{
            method: :redirect_key,
            router: MishkaHtmlWeb.AdminCommentLive,
            title: MishkaTranslator.Gettext.dgettext("html_live", "ویرایش"),
            class: "btn btn-outline-danger vazir",
            action: :id,
            key: :id
          }
        ]
      },
      title: @section_title,
      activities_info: %{
        title: MishkaTranslator.Gettext.dgettext("html_live_templates", "نظرات"),
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "نظر"),
        action: :user_full_name,
        action_by: :user_full_name
      },
      custom_operations: nil,
      description: ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "شما در این بخش می توانید نظرات ارسالی از طرف کاربران را مدیریت نمایید.") %>
        <div class="space30"></div>
      """
    }
  end
end
