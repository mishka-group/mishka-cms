defmodule MishkaHtmlWeb.HomeLive do
  use MishkaHtmlWeb, :live_view

  # TODO: we need to input seo tags
  # TODO: paginate

  alias MishkaContent.Blog.Post

  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_title: "تگرگ",
        body_color: "#40485d",
        user_id: Map.get(session, "user_id"),
        page_size: 12,
        filters: %{},
        page: 1,
        posts: Post.posts(conditions: {1, 12}, filters: %{}, user_id: Map.get(session, "user_id")),
        featured_posts: Post.posts(conditions: {1, 5}, filters: %{priority: "featured"}, user_id: Map.get(session, "user_id"))
      )

    {:ok, socket, temporary_assigns: [posts: [], featured_posts: []]}
  end

  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.HomeLive"})
    {:noreply, socket}
  end
end
