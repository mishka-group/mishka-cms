defmodule MishkaHtmlWeb.AdminBlogPostAuthorsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Author

  @impl true
  def mount(%{"post_id" => post_id}, _session, socket) do
    socket = case MishkaContent.Blog.Post.show_by_id(post_id) do
      {:ok, :get_record_by_id, _error_tag, _record} ->
        Process.send_after(self(), :menu, 100)
        assign(socket,
          page_title: "مدیریت نویسندگان",
          body_color: "#a29ac3cf",
          authors: Author.authors(post_id),
          search_author: [],
          post_id: post_id
        )

      _ ->
        socket
        |> put_flash(:error, "چنین مطلبی وجود ندارد یا از قبل حذف شده است.")
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive))
    end

    {:ok, socket}
  end

  @impl true
  def handle_event("add_author", %{"user-id" => user_id}, socket) do
    socket = case Author.create(%{post_id: socket.assigns.post_id, user_id: user_id}) do
      {:ok, :add, :blog_author, _record} ->
        socket
        |> put_flash(:info, "نویسنده با موفقت ثبت شد.")

      _ ->
        socket
        |> put_flash(:error, "کاربر تکراری امکان ثبت ندارد. یا ممکن است در موقع ثبت کاربر مذکور حذف شده باشد.")
    end
    |> push_redirect(to: Routes.live_path(socket, __MODULE__, socket.assigns.post_id))

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    socket = case Author.delete(id) do
      {:ok, :delete, :blog_author, repo_data} ->
        socket
        |> put_flash(:info, "نویسنده با موفقت حذف شد")
        |> assign(authors: Author.authors(repo_data.post_id))

      _ ->

        socket
        |> put_flash(:warning, "خطایی در حذف نویسنده پیش آمده است.")
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("search_user", %{"full_name" => full_name, "role" => role}, socket) do

    filters =
      [{:full_name, full_name}, {:role, role}]
      |> Enum.reject(fn {_k, v} -> v == "" end)
      |> Enum.into(%{})

    search_author = MishkaUser.User.users(conditions: {1, 10}, filters: filters)

    socket =
      socket
      |> assign(search_author: search_author)

    {:noreply, socket}
  end


  @impl true
  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminBlogPostAuthorsLive"})
    {:noreply, socket}
  end
end