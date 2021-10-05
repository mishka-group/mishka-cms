defmodule MishkaHtmlWeb.AdminBlogPostTagsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Tag
  alias MishkaContent.Blog.TagMapper
  alias MishkaContent.Blog.Post

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.TagMapper,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminBlogView, "admin_blog_post_tags_live.html", assigns)
  end

  @impl true
  def mount(%{"id" => post_id}, session, socket) do

    if connected?(socket) do
      Tag.subscribe()
      TagMapper.subscribe()
    end

    socket = case Post.show_by_id(post_id) do
      {:error, :get_record_by_id, _error_atom} ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین مطلبی وجود ندارد یا ممکن است از قبل حذف شده باشد."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive))

      {:ok, :get_record_by_id, _error_atom, repo_data} ->
        Process.send_after(self(), :menu, 100)
        socket
        |> assign(
          post_id: post_id,
          page_title: "#{repo_data.title}",
          body_color: "#a29ac3cf",
          user_id: Map.get(session, "user_id"),
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
    MishkaContent.General.Activity.create_activity_by_task(%{
      type: "section",
      section: "blog_tag",
      section_id: tag_id,
      action: "delete",
      priority: "low",
      status: "info",
      user_id: socket.assigns.user_id
    }, %{post_id: socket.assigns.post_id})

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
    socket = case TagMapper.create(%{post_id: socket.assigns.post_id, tag_id: tag_id}) do
      {:error, :add, _error_tag, _repo_error} -> socket

      {:ok, :add, _error_tag, repo_data} ->
        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: "blog_tag",
          section_id: repo_data.id,
          action: "add",
          priority: "low",
          status: "info",
          user_id: socket.assigns.user_id
        }, %{post_id: socket.assigns.post_id})
        socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({tag, :ok, repo_record}, socket) when tag in [:blog_tag_mapper, :tag] do
    socket = case repo_record.__meta__.state do
      :loaded ->
        Notif.notify_subscribers(%{id: repo_record.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "یک برچسب به مطلب %{title} اضافه شد", title: socket.assigns.page_title)})
        socket
        |> assign(tags: Tag.post_tags(socket.assigns.post_id))

      :deleted ->
        Notif.notify_subscribers(%{id: repo_record.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "یک برچسب از مطلب %{title} حذف شد.", title: socket.assigns.page_title)})
        socket
        |> assign(tags: Tag.post_tags(socket.assigns.post_id))

       _ ->  socket
    end
    {:noreply, socket}
  end

  selected_menue("MishkaHtmlWeb.AdminBlogPostTagsLive")
end
