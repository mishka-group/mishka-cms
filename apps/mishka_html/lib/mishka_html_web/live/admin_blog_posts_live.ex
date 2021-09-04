defmodule MishkaHtmlWeb.AdminBlogPostsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Post


  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.Post,
      redirect: __MODULE__,
      router: Routes,
      skip_list: ["category_title"]


  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminBlogView, "admin_blog_posts_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Post.subscribe()
    Process.send_after(self(), :menu, 100)
    user_id = Map.get(session, "user_id")
    socket =
      assign(socket,
        page_size: 10,
        user_id: Map.get(session, "user_id"),
        filters: %{},
        page: 1,
        open_modal: false,
        component: nil,
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت مطالب"),
        body_color: "#a29ac3cf",
        posts: Post.posts(conditions: {1, 10}, filters: %{}, user_id: user_id),
        fpost: Post.posts(conditions: {1, 5}, filters: %{priority: :featured}, user_id: user_id),
      )
    {:ok, socket, temporary_assigns: [posts: []]}
  end

  # Live CRUD
  paginate(:posts, user_id: true)

  list_search_and_action()

  @impl true
  def handle_event("delete", %{"id" => id} = _params, socket) do
    socket = case Post.delete(id) do
      {:ok, :delete, :post, repo_data} ->
        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "مطلب: %{title} حذف شده است.", title: MishkaHtml.title_sanitize(repo_data.title))})
        post_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

      {:error, :delete, :forced_to_delete, :post} ->
          socket
          |> assign([
            open_modal: true,
            component: MishkaHtmlWeb.Admin.Blog.Post.DeleteErrorComponent
          ])

      {:error, :delete, type, :post} when type in [:uuid, :get_record_by_id] ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین مطلبی ای وجود ندارد یا ممکن است از قبل حذف شده باشد."))

      {:error, :delete, :post, _repo_error} ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "خطا در حذف مطلب اتفاق افتاده است."))
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("featured_post", %{"id" => id} = _params, socket) do
    socket =
      socket
      |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostLive, id: id))
    {:noreply, socket}
  end

  @impl true
  def handle_info({:post, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        post_assign(
          socket,
          params: socket.assigns.filters,
          page_size: socket.assigns.page_size,
          page_number: socket.assigns.page,
        )

       _ ->  socket
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminBlogPostsLive"})
    {:noreply, socket}
  end

  defp post_filter(params) when is_map(params) do
    Map.take(params, Post.allowed_fields(:string) ++ ["category_title"])
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Map.new()
    |> MishkaDatabase.convert_string_map_to_atom_map()
  end

  defp post_filter(_params), do: %{}


  defp post_assign(socket, params: params, page_size: count, page_number: page) do
    assign(socket,
        [
          posts: Post.posts(conditions: {page, count}, filters: post_filter(params), user_id: socket.assigns.user_id),
          page_size: count,
          filters: params,
          page: page
        ]
      )
  end
end
