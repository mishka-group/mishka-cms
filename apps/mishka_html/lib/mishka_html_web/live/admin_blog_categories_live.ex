defmodule MishkaHtmlWeb.AdminBlogCategoriesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Category
  alias MishkaHtmlWeb.Admin.Blog.Category.DeleteErrorComponent
  alias MishkaContent.General.Activity

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.Category,
      redirect: __MODULE__,
      router: Routes


  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminBlogView, "admin_blog_categories_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Category.subscribe()
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
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت مجموعه ها"),
        categories: Category.categories(conditions: {1, 10}, filters: %{}),
        activities: Activity.activities(conditions: {1, 5}, filters: %{})
      )
    {:ok, socket, temporary_assigns: [categories: []]}
  end

  # Live CRUD and Paginate
  paginate(:categories, user_id: false)

  list_search_and_action()

  delete_list_item(:categories, DeleteErrorComponent, false)

  selected_menue("MishkaHtmlWeb.AdminBlogCategoriesLive")

  update_list(:categories, false)
end
