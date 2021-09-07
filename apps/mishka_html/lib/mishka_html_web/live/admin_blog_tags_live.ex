defmodule MishkaHtmlWeb.AdminBlogTagsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Tag
  # alias MishkaHtmlWeb.Admin.Tag.DeleteErrorComponent

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.Tag,
      redirect: __MODULE__,
      router: Routes


  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminBlogView, "admin_blog_tags_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Tag.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت برچسب ها"),
        body_color: "#a29ac3cf",
        filters: %{},
        page_size: 10,
        filters: %{},
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

  update_list(:tags, false)

  selected_menue("MishkaHtmlWeb.AdminBlogTagsLive")
end
