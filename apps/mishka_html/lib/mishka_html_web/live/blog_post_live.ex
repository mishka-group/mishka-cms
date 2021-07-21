defmodule MishkaHtmlWeb.BlogPostLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.{Category, Post}

  def mount(%{"alias_link" => _alias_link}, session, socket) do
    if connected?(socket) do
      Post.subscribe()
    end
    # we need to input seo tags
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_title: "بلاگ",
        body_color: "#40485d",
        user_id: Map.get(session, "user_id"),
        post: Post.post(Ecto.UUID.generate, "active"),
      )
      {:ok, socket, temporary_assigns: [posts: [], categories: [], featured_posts: []]}
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.BlogPostLive"})
    {:noreply, socket}
  end
end
