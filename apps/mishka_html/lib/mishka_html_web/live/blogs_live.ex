defmodule MishkaHtmlWeb.BlogsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.{Category, Post}

  def mount(_params, session, socket) do
    if connected?(socket) do
      Category.subscribe()
      Post.subscribe()
    end
    # we need to input seo tags
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_title: "بلاگ",
        body_color: "#40485d",
        user_id: Map.get(session, "user_id"),
        posts: Post.posts(conditions: {1, 20}, filters: %{}),
        categories: Category.categories(filters: %{})
      )
      {:ok, socket, temporary_assigns: [posts: [], categories: []]}
  end

  @impl true
  def handle_params(%{"page" => page}, _url, socket) do
    socket =
      socket
      |> assign([posts: Post.posts(conditions: {page, 20}, filters: %{}), page: page])
    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.BlogsLive"})
    {:noreply, socket}
  end

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

  defp priority(priority) do
    case priority do
      :none -> "ندارد"
      :low -> "پایین"
      :medium -> "متوسط"
      :high -> "بالا"
      :featured -> "ویژه"
    end
  end
end
