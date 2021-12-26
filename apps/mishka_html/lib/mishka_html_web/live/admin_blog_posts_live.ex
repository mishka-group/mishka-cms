defmodule MishkaHtmlWeb.AdminBlogPostsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Post
  alias MishkaHtmlWeb.Admin.Blog.Post.DeleteErrorComponent
  alias MishkaContent.General.Activity
  @section_title MishkaTranslator.Gettext.dgettext("html_live", "مدیریت مطالب")

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.Post,
      redirect: __MODULE__,
      router: Routes,
      skip_list: ["category_title"]

  @impl true
  def render(assigns) do
    ~H"""
      <.live_component
        module={MishkaHtml.Helpers.ListContainerComponent}
        id={:list_container}
        flash={@flash}
        section_info={section_info(assigns, @socket)}
        filters={@filters}
        list={@posts}
        url={MishkaHtmlWeb.AdminBlogPostsLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, MishkaHtmlWeb.Admin.Public.AdminMenu, id: :admin_menu)}
        left_header_side={MishkaHtmlWeb.Helpers.ActivitiesComponent.activities(assigns, section_info(assigns, @socket).activities_info)}
      />
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Post.subscribe(); Activity.subscribe()
    Process.send_after(self(), :menu, 100)
    user_id = Map.get(session, "user_id")
    socket =
      assign(socket,
        page_size: 10,
        user_id: Map.get(session, "user_id"),
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        page_title: @section_title,
        body_color: "#a29ac3cf",
        posts: Post.posts(conditions: {1, 10}, filters: %{}, user_id: user_id),
        fpost: Post.posts(conditions: {1, 5}, filters: %{priority: :featured}, user_id: user_id),
        activities: Activity.activities(conditions: {1, 5}, filters: %{section: "blog_post"})
      )
    {:ok, socket, temporary_assigns: [posts: []]}
  end

  # Live CRUD
  paginate(:posts, user_id: true)

  list_search_and_action()

  delete_list_item(:posts, DeleteErrorComponent, true)

  @impl true
  def handle_event("featured_post", %{"id" => id} = _params, socket) do
    socket =
      socket
      |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostLive, id: id))
    {:noreply, socket}
  end

  selected_menue("MishkaHtmlWeb.AdminBlogPostsLive")

  @impl true
  def handle_info({:activity, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        socket
        |> assign(
          activities: Activity.activities(conditions: {1, 5}, filters: %{section: "blog_post"}),
          posts: Post.posts(conditions: {socket.assigns.page, socket.assigns.page_size}, filters: socket.assigns.filters, user_id: socket.assigns.user_id)
        )
       _ ->  socket
    end

    {:noreply, socket}
  end

  update_list(:posts, true)

  def section_fields() do
    [
      ListItemComponent.upload_field("main_image", [1], "col-sm-2 header1", MishkaTranslator.Gettext.dgettext("html_live",  "تصویر"),
      {true, true, false}),
      ListItemComponent.text_field("title", [1], "col header2", MishkaTranslator.Gettext.dgettext("html_live",  "تیتر"),
      {false, true, true}, &MishkaHtml.title_sanitize/1),
      ListItemComponent.link_field("title", [1], "col header2", MishkaTranslator.Gettext.dgettext("html_live",  "تیتر"),
      {MishkaHtmlWeb.AdminBlogPostLive, :id},
      {true, false, false}, &MishkaHtml.title_sanitize/1),
      ListItemComponent.link_field("category_title", [1], "col header3", MishkaTranslator.Gettext.dgettext("html_live",  "مجموعه"),
      {MishkaHtmlWeb.AdminBlogCategoryLive, :category_id},
      {true, false, false}, &MishkaHtml.title_sanitize/1),
      ListItemComponent.text_field("category_title", [1], "col header3", MishkaTranslator.Gettext.dgettext("html_live",  "مجموعه"),
      {false, true, true}, &MishkaHtml.title_sanitize/1),
      ListItemComponent.select_field("status", [1, 4], "col header4", MishkaTranslator.Gettext.dgettext("html_live",  "وضعیت"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "غیر فعال"), "inactive"},
        {MishkaTranslator.Gettext.dgettext("html_live", "فعال"), "active"},
        {MishkaTranslator.Gettext.dgettext("html_live", "آرشیو شده"), "archived"},
        {MishkaTranslator.Gettext.dgettext("html_live", "حذف با پرچم"), "soft_delete"}
      ],
      {true, true, true}),
      ListItemComponent.select_field("priority", [1, 4], "col header5", MishkaTranslator.Gettext.dgettext("html_live",  "اولویت"),
      [
        {MishkaTranslator.Gettext.dgettext("html_live", "ندارد"), "none"},
        {MishkaTranslator.Gettext.dgettext("html_live", "پایین"), "low"},
        {MishkaTranslator.Gettext.dgettext("html_live", "متوسط"), "medium"},
        {MishkaTranslator.Gettext.dgettext("html_live", "بالا"), "high"},
        {MishkaTranslator.Gettext.dgettext("html_live", "ویژه"), "featured"}
      ],
      {true, true, true}),
      ListItemComponent.select_field("robots", [3, 5, 6], "col header6", MishkaTranslator.Gettext.dgettext("html_live",  "رباط"),
      [
        {"IndexFollow", "IndexFollow"},
        {"IndexNoFollow", "IndexNoFollow"},
        {"NoIndexFollow", "NoIndexFollow"},
        {"NoIndexNoFollow", "NoIndexNoFollow"}
      ],
      {true, true, true}),
      ListItemComponent.time_field("updated_at", [1], "col header7", MishkaTranslator.Gettext.dgettext("html_live",  "به روز رسانی"), false,
      {true, false, false})
    ]
  end

  def section_info(assigns, socket) do
    %{
      section_btns: %{
        header: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "مطلب جدید"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostLive),
            class: "btn btn-outline-primary"
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "مجموعه ها"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogCategoriesLive),
            class: "btn btn-outline-danger"
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
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "برچسب ها"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogTagsLive),
            class: "btn btn-outline-warning"
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
            method: :redirect_keys,
            router: MishkaHtmlWeb.AdminCommentsLive,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "نظرات"),
            class: "btn btn-outline-success vazir",
            keys: [
              {:section_id, :id},
              {:count, "30"},
            ]
          },
          %{
            method: :redirect,
            router: MishkaHtmlWeb.AdminBlogPostAuthorsLive,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "نویسندگان"),
            class: "btn btn-outline-secondary vazir",
            action: :id
          },
          %{
            method: :redirect,
            router: MishkaHtmlWeb.AdminBlogPostTagsLive,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "برچسب ها"),
            class: "btn btn-warning vazir",
            action: :id
          },
          %{
            method: :redirect,
            router: MishkaHtmlWeb.AdminLinksLive,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "لینک ها"),
            class: "btn btn-outline-info vazir",
            action: :id
          }
        ]
      },
      title: @section_title,
      activities_info: %{
        title: MishkaTranslator.Gettext.dgettext("html_live_component", "آخرین فعالیت ها در تولید محتوا"),
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "مطلب"),
        action: :title,
        action_by: :full_name,
      },
      description:
      ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_component", "شما در این بخش می توانید مطالب ارسالی در سایت را مدیریت و ویرایش نمایید.") %>
        <div class="space20"></div>
        <hr>
        <div class="space40"></div>
        <h3 class="admin-dashbord-h3-right-side-title vazir"><%= MishkaTranslator.Gettext.dgettext("html_live_component", "مطالب ویژه") %></h3>
        <span class="admin-dashbord-right-side-text vazir">
        <%= MishkaTranslator.Gettext.dgettext("html_live_component", "در این بخش می توانید چند مطلب ویژه آخر را ببنید برای دیدن کلیه مطالب ویژه از فیلد های جستجو استفاده کنید.") %>
        </span>
        <div class="space30"></div>
        <div class="row">
          <%= for post <- @fpost do %>
            <div phx-value-id={post.id} phx-click="featured_post" class="col-sm-2 admin-featured-post-item" style={"
              background-image: url(#{post.main_image});
              background-repeat: no-repeat;
              box-shadow: 1px 1px 8px #dadada;
              background-size: cover;
              min-height: 100px;
              margin: 10px;
              background-position: center center;
            "}></div>
          <% end %>
        </div>
      """
    }
  end
end
