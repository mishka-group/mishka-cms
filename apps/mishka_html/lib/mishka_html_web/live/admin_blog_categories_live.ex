defmodule MishkaHtmlWeb.AdminBlogCategoriesLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Category

  def mount(_params, _session, socket) do
    socket = assign(socket, :categories, Category.categories(filters: %{}))
    {:ok, socket,temporary_assigns: [categories: []]}
  end

end
