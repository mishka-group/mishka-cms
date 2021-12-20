defmodule MishkaHtmlWeb.AdminBlogTagsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Tag
  @section_title MishkaTranslator.Gettext.dgettext("html_live", "مدیریت برچسب ها")

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.Tag,
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
        list={@tags}
        url={MishkaHtmlWeb.AdminBlogTagsLive}
        page_size={@page_size}
        parent_assigns={assigns}
        admin_menu={live_render(@socket, AdminMenu, id: :admin_menu)}
        left_header_side=""
      />
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Tag.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_title: @section_title,
        body_color: "#a29ac3cf",
        filters: %{},
        page_size: 10,
        filters: %{},
        user_id: Map.get(session, "user_id"),
        page: 1,
        open_modal: false,
        component: nil,
        tags: Tag.tags(conditions: {1, 10}, filters: %{})
      )

    {:ok, socket, temporary_assigns: [tags: []]}
  end

  # Live CRUD
  paginate(:tags, user_id: false)

  list_search_and_action()

  delete_list_item(:tags, DeleteErrorComponent, false)

  selected_menue("MishkaHtmlWeb.AdminBlogTagsLive")

  update_list(:tags, false)

  def section_fields() do
    [
      ListItemComponent.text_field("title", [1], "col header1", MishkaTranslator.Gettext.dgettext("html_live",  "تیتر"),
      {false, true, true}),
      ListItemComponent.link_field("title", [1], "col header1", MishkaTranslator.Gettext.dgettext("html_live",  "تیتر"),
      {MishkaHtmlWeb.AdminBlogTagLive, :id},
      {true, false, false}),
      ListItemComponent.text_field("custom_title", [1], "col header2", MishkaTranslator.Gettext.dgettext("html_live",  "تیتر سفارشی"),
      {true, true, true}),
      ListItemComponent.select_field("robots", [3, 5, 6], "col header3", MishkaTranslator.Gettext.dgettext("html_live",  "رباط"),
      [
        {"IndexFollow", "IndexFollow"},
        {"IndexNoFollow", "IndexNoFollow"},
        {"NoIndexFollow", "NoIndexFollow"},
        {"NoIndexNoFollow", "NoIndexNoFollow"}
      ],
      {true, true, true}),
      ListItemComponent.time_field("inserted_at", [1], "col header4", MishkaTranslator.Gettext.dgettext("html_live",  "ثبت"), false,
      {true, false, false}),
      ListItemComponent.time_field("updated_at", [1], "col header5", MishkaTranslator.Gettext.dgettext("html_live",  "به روز رسانی"), false,
      {true, false, false})
    ]
  end

  def section_info(assigns, socket) do
    %{
      section_btns: %{
        header: [
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "برچسب جدید"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogTagLive),
            class: "btn btn-outline-primary"
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "مطالب"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive),
            class: "btn btn-outline-danger"
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "مجموعه ها"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogCategoriesLive),
            class: "btn btn-outline-info"
          },
          %{
            title: MishkaTranslator.Gettext.dgettext("html_live_templates", "مدیریت سئو"),
            router: Routes.live_path(socket, MishkaHtmlWeb.AdminSeoLive),
            class: "btn btn-outline-success"
          }
        ],
        list_item: [
          %{
            method: :delete,
            router: nil,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "حذف"),
            class: "btn btn-outline-danger vazir"
          },
          %{
            method: :redirect_key,
            router: MishkaHtmlWeb.AdminBlogTagLive,
            title: MishkaTranslator.Gettext.dgettext("html_live",  "ویرایش"),
            class: "btn btn-outline-info vazir",
            action: :id
          }
        ]
      },
      title: @section_title,
      activities_info: %{
        title: MishkaTranslator.Gettext.dgettext("html_live_templates", "مدیریت برچسب ها"),
        section_type: MishkaTranslator.Gettext.dgettext("html_live_component", "برچسب"),
        action: :section,
        action_by: :section,
      },
      custom_operations: nil,
      description:
      ~H"""
        <%= MishkaTranslator.Gettext.dgettext("html_live_templates", "شما در این بخش می توانید برچسب های مطالب را مدیریت نمایید.") %>
        <div class="space30"></div>
      """
    }
  end
end
