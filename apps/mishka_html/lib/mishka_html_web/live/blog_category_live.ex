defmodule MishkaHtmlWeb.BlogCategoryLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.{Category, Post}

  @impl true
  def mount(%{"alias_link" => _alias_link}, session, socket) do
    if connected?(socket) do
      Category.subscribe()
      Post.subscribe()
    end

    Process.send_after(self(), :menu, 100)
    # we need to input seo tags
    socket =
      assign(socket,
        page_title: "بلاگ",
        body_color: "#40485d",
        user_id: Map.get(session, "user_id"),
        posts: Post.posts(conditions: {1, 20}, filters: %{}, user_id: Map.get(session, "user_id")),
        featured_posts: [],
        categories: Category.categories(conditions: {1, 20}, filters: %{})
      )
      {:ok, socket, temporary_assigns: [posts: [], categories: [], featured_posts: []]}
  end

  @impl true
  def handle_params(%{"page" => page}, _url, socket) do
      # after categoey exist show category posts featured (Post.posts(conditions: {1, 5}, filters: %{priority: :featured}))
      # chenge page_title: "بلاگ" to category exists name
      socket =
        socket
        |> assign([posts: Post.posts(conditions: {page, 20}, filters: %{}, user_id: socket.assigns.user_id), page: page])
    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end


  # it should be noted if category id and post id are same the state, then do refresh or sth


  # @impl true
  # def handle_info({:category, :ok, repo_record}, socket) do
  #   case repo_record.__meta__.state do
  #     :loaded ->

  #       socket = category_assign(
  #         socket,
  #         params: socket.assigns.filters,
  #         page_size: socket.assigns.page_size,
  #         page_number: socket.assigns.page,
  #       )

  #       {:noreply, socket}

  #     :deleted -> {:noreply, socket}
  #      _ ->  {:noreply, socket}
  #   end
  # end

  # def handle_info({:post, :ok, repo_record}, socket) do
  #   case repo_record.__meta__.state do
  #     :loaded ->

  #       socket = post_assign(
  #         socket,
  #         params: socket.assigns.filters,
  #         page_size: socket.assigns.page_size,
  #         page_number: socket.assigns.page,
  #       )

  #       {:noreply, socket}

  #     :deleted -> {:noreply, socket}
  #      _ ->  {:noreply, socket}
  #   end
  # end

  @impl true
  def handle_info(:menu, socket) do
    # it should be shown in Blogs menue
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.BlogsLive"})
    {:noreply, socket}
  end
end
