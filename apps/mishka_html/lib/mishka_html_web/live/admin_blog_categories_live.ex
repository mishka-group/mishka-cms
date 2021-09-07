defmodule MishkaHtmlWeb.AdminBlogCategoriesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Category
  alias MishkaHtmlWeb.Admin.Blog.Category.DeleteErrorComponent

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.Category,
      redirect: __MODULE__,
      router: Routes


  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminBlogView, "admin_blog_categories_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Category.subscribe()
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_size: 10,
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        body_color: "#a29ac3cf",
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت مجموعه ها"),
        categories: Category.categories(conditions: {1, 10}, filters: %{})
      )
    {:ok, socket, temporary_assigns: [categories: []]}
  end

  # Live CRUD and Paginate
  paginate(:categories, user_id: false)

  list_search_and_action()

  delete_list_item(:categories, DeleteErrorComponent, false)

  update_list(:categories, false)

  selected_menue("MishkaHtmlWeb.AdminBlogCategoriesLive")

end
