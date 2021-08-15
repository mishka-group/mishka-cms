defmodule MishkaHtmlWeb.AdminBlogPostTagsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Tag
  alias MishkaContent.Blog.TagMapper
  alias MishkaContent.Blog.Post

  @impl true
  def mount(%{"id" => post_id}, _session, socket) do

    if connected?(socket) do
      Tag.subscribe()
      TagMapper.subscribe()
    end

    socket = case Post.show_by_id(post_id) do
      {:error, :get_record_by_id, _error_atom} ->
        socket
        |> put_flash(:warning, "چنین مطلبی وجود ندارد یا ممکن است از قبل حذف شده باشد.")
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive))

      {:ok, :get_record_by_id, _error_atom, repo_data} ->
        Process.send_after(self(), :menu, 100)
        socket
        |> assign(
          post_id: post_id,
          page_title: "#{repo_data.title}",
          body_color: "#a29ac3cf",
          id: nil,
          tags: Tag.post_tags(post_id),
          search: []
        )
      end

      {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => tag_id} = _params, socket) do
    TagMapper.delete(socket.assigns.post_id, tag_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("search_tag", %{"_target" => _target, "search-tag-title" => tag_title}, socket) do
    search_tags = Tag.tags(conditions: {1, 5}, filters: %{title: tag_title}).entries
    socket =
      socket
      |> assign(search: search_tags)

    {:noreply, socket}
  end

  def handle_event("search_tag", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("add_tag", %{"id" => tag_id}, socket) do
    TagMapper.create(%{post_id: socket.assigns.post_id, tag_id: tag_id})
    {:noreply, socket}
  end

  @impl true
  def handle_info({tag, :ok, repo_record}, socket) when tag in [:blog_tag_mapper, :tag] do
    socket = case repo_record.__meta__.state do
      :loaded ->
        Notif.notify_subscribers(%{id: repo_record.id, msg: "یک برچسب به مطلب #{socket.assigns.page_title} اضافه شد"})
        socket
        |> assign(tags: Tag.post_tags(socket.assigns.post_id))

      :deleted ->
        Notif.notify_subscribers(%{id: repo_record.id, msg: "یک برچسب از مطلب #{socket.assigns.page_title} حذف شد."})
        socket
        |> assign(tags: Tag.post_tags(socket.assigns.post_id))

       _ ->  socket
    end
    {:noreply, socket}
  end

  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminBlogPostTagsLive"})
    {:noreply, socket}
  end

end
