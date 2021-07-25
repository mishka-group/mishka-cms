defmodule MishkaHtmlWeb.BlogsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.{Category, Post, Like}

  def mount(_params, session, socket) do
    if connected?(socket) do
      Category.subscribe()
      Post.subscribe()
    end
    # we need to input seo tags
    Process.send_after(self(), :menu, 100)
    user_id = Map.get(session, "user_id")
    socket =
      assign(socket,
        page_title: "بلاگ",
        body_color: "#40485d",
        user_id: Map.get(session, "user_id"),
        posts: Post.posts(conditions: {1, 20}, filters: %{}, user_id: if(!is_nil(user_id), do: user_id, else: Ecto.UUID.generate)),
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

  def handle_event("like_post", %{"post-id" => post_id}, socket) do

    with {:user_id, false} <- {:user_id, is_nil(socket.assigns.user_id)},
         {:error, :show_by_user_and_post_id, :not_found} <- Like.show_by_user_and_post_id(socket.assigns.user_id, post_id),
         {:ok, :add, :post_like, _like_info} <- Like.create(%{"user_id" => socket.assigns.user_id, "post_id" => post_id}) do

          IO.inspect("yes did it")
          # TODO: we need to update list with filters after creating or update just the record we want or let the handle info to do this
          socket
    else
      {:ok, :show_by_user_and_post_id, liked_record} ->
        # TODO: we need to update list with filters after deleting or let the handle info to do this

        Like.delete(liked_record.id)
        socket

      {:error, :show_by_user_and_post_id, :cast_error}  ->
        # TODO: we need to add flash error sth wrong and tell the user refresh the page
        socket

      {:user_id, false} ->
        # TODO: I thinks the user want to be a noob atacker then let him try more without any reaction
        socket
    end

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
