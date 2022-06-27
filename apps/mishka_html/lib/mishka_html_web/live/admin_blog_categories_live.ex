defmodule MishkaHtmlWeb.AdminBlogCategoriesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Category
  alias MishkaContent.General.Activity

  @section_title MishkaTranslator.Gettext.dgettext("html_live", "مدیریت مجموعه ها")

  use MishkaHtml.Helpers.LiveCRUD,
    module: MishkaContent.Blog.Category,
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
        list={@categories}
        url={MishkaHtmlWeb.AdminBlogCategoriesLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, AdminMenu, id: :admin_menu)}
        left_header_side={MishkaHtmlWeb.Helpers.ActivitiesComponent.activities(assigns, section_info(assigns, @socket).activities_info)}
      />
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Category.subscribe()
    Activity.subscribe()
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
        page_title: @section_title,
        categories: Category.categories(conditions: {1, 10}, filters: %{}),
        activities: Activity.activities(conditions: {1, 5}, filters: %{section: "blog_category"})
      )

    {:ok, socket, temporary_assigns: [categories: []]}
  end

  # Live CRUD and Paginate
  paginate(:categories, user_id: false)

  list_search_and_action()

  delete_list_item(:categories, DeleteErrorComponent, false)

  selected_menue("MishkaHtmlWeb.AdminBlogCategoriesLive")

  @impl true
  def handle_info({:activity, :ok, repo_record}, socket) do
    socket =
      case repo_record.__meta__.state do
        :loaded ->
          socket
          |> assign(
            activities:
              Activity.activities(conditions: {1, 5}, filters: %{section: "blog_category"}),
            categories:
              Category.categories(
                conditions: {socket.assigns.page, socket.assigns.page_size},
                filters: socket.assigns.filters
              )
          )

        _ ->
          socket
      end

    {:noreply, socket}
  end

  update_list(:categories, false)

  def section_fields() do
    [
      ListItemComponent.upload_field(
        "main_image",
        [1],
        "col-sm-2 header1",
        MishkaTranslator.Gettext.dgettext("html_live", "تصویر"),
        {true, true, false}
      ),
      ListItemComponent.text_field(
        "title",
        [1],
        "col header2",
        MishkaTranslator.Gettext.dgettext("html_live", "تیتر"),
        {false, true, true},
        &MishkaHtml.title_sanitize/1
      ),
      ListItemComponent.link_field(
        "title",
        [1],
        "col header2",
        MishkaTranslator.Gettext.dgettext("html_live", "تیتر"),
        {MishkaHtmlWeb.AdminBlogCategoryLive, :id},
        {true, false, false},
        &MishkaHtml.title_sanitize/1
      ),
      ListItemComponent.select_field(
        "category_visibility",
        [1, 4],
        "col header3",
        MishkaTranslator.Gettext.dgettext("html_live", "حالت نمایش"),
        [
          {MishkaTranslator.Gettext.dgettext("html_live", "نمایش"), "show"},
          {MishkaTranslator.Gettext.dgettext("html_live", "مخفی"), "invisibel"},
          {MishkaTranslator.Gettext.dgettext("html_live", "نمایش تست"), "test_show"},
          {MishkaTranslator.Gettext.dgettext("html_live", "مخفی تست"), "test_invisibel"}
        ],
        {true, true, true}
      ),
      ListItemComponent.select_field(
        "status",
        [1, 4],
        "col header4",
        MishkaTranslator.Gettext.dgettext("html_live", "وضعیت"),
        [
          {MishkaTranslator.Gettext.dgettext("html_live", "غیر فعال"), "inactive"},
          {MishkaTranslator.Gettext.dgettext("html_live", "فعال"), "active"},
          {MishkaTranslator.Gettext.dgettext("html_live", "آرشیو شده"), "archived"},
          {MishkaTranslator.Gettext.dgettext("html_live", "حذف با پرچم"), "soft_delete"}
        ],
        {true, true, true}
      ),
      ListItemComponent.time_field(
        "updated_at",
        [1],
        "col header5",
        MishkaTranslator.Gettext.dgettext("html_live", "به روز رسانی"),
        false,
        {true, false, false}
      )
    ]
  end

  def section_info(_assigns, socket) do
    %{
      section_btns: %{
        header: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "مجموعه جدید"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogCategoryLive),
            class: "btn btn-outline-primary"
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "نظرات"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminCommentsLive),
            class: "btn btn-outline-info"
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "تنظیمات سئو"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminSeoLive),
            class: "btn btn-outline-success"
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "مطالب"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive),
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
            router: MishkaHtmlWeb.AdminBlogCategoryLive,
            title: MishkaTranslator.Gettext.dgettext("html_live", "ویرایش"),
            class: "btn btn-outline-success vazir",
            action: :id
          }
        ]
      },
      title: @section_title,
      activities_info: %{
        title:
          MishkaTranslator.Gettext.dgettext(
            "html_live_component",
            "آخرین فعالیت ها در تولید محتوا"
          ),
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "مجموعه"),
        action: :title,
        action_by: :full_name
      },
      description:
        MishkaTranslator.Gettext.dgettext(
          "html_live_templates",
          "در این بخش می توانید مجموعه های مربوط به بخش مطالب را مدیریت کنید."
        )
    }
  end
end
