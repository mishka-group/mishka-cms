defmodule MishkaHtmlWeb.AdminLinksLive do
  use MishkaHtmlWeb, :live_view
  alias MishkaContent.Blog.BlogLink
  alias MishkaContent.Blog.Post

  use MishkaHtml.Helpers.LiveCRUD,
      module: MishkaContent.Blog.BlogLink,
      redirect: __MODULE__,
      router: Routes

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminBlogView, "admin_links_live.html", assigns)
  end

  @impl true
  def mount(%{"id" => post_id}, session, socket) do
    socket = case Post.show_by_id(post_id) do
      {:ok, :get_record_by_id, _error_tag, record} ->
        if connected?(socket), do: BlogLink.subscribe()
        Process.send_after(self(), :menu, 100)
        assign(socket,
          page_title: MishkaTranslator.Gettext.dgettext("html_live", "مطلب %{title}", title: record.title),
          body_color: "#a29ac3cf",
          user_id: Map.get(session, "user_id"),
          post_links: BlogLink.links(filters: %{section_id: post_id}),
          post_id: post_id,
          link_id: nil
        )

      _ ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "چنین مطلبی وجود ندارد یا از قبل حذف شده است."))
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.AdminBlogPostsLive))
    end

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id} = _params, socket) do
    socket = case BlogLink.delete(id) do
      {:ok, :delete, :blog_link, repo_data} ->
        MishkaContent.General.Activity.create_activity_by_task(%{
          type: "section",
          section: "blog_link",
          section_id: repo_data.id,
          action: "delete",
          priority: "medium",
          status: "info",
          user_id: socket.assigns.user_id
        }, %{post_id: socket.assigns.post_id})

        Notif.notify_subscribers(%{id: repo_data.id, msg: MishkaTranslator.Gettext.dgettext("html_live", "لینک: %{title} حذف شده است.", title: MishkaHtml.title_sanitize(repo_data.title))})
        socket
        |> put_flash(:info, MishkaTranslator.Gettext.dgettext("html_live", "لینک با موفقیت حذف شد"))

      {:error, :delete, type, :blog_link} when type in [:uuid, :get_record_by_id] ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live", "چنین لینکی وجود ندارد یا ممکن است از قبل حذف شده باشد."))

      {:error, :delete, :blog_link, _repo_error} ->
        socket
        |> put_flash(:error, MishkaTranslator.Gettext.dgettext("html_live", "خطا در حذف لینک اتفاق افتاده است."))
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:blog_link, :ok, repo_record}, socket) do
    socket = case repo_record.__meta__.state do
      :loaded ->
        assign(socket,
          post_links: BlogLink.links(filters: %{section_id: socket.assigns.post_id})
        )

      :deleted ->
        assign(socket,
          post_links: BlogLink.links(filters: %{section_id: socket.assigns.post_id})
        )
       _ ->  socket
    end

    {:noreply, socket}
  end


  selected_menue("MishkaHtmlWeb.AdminPostLinksLive")
end
