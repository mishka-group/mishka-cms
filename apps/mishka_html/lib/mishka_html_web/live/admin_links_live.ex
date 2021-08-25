defmodule MishkaHtmlWeb.AdminLinksLive do
  use MishkaHtmlWeb, :live_view
  alias MishkaContent.Blog.BlogLink
  alias MishkaContent.Blog.Post

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.AdminBlogView, "admin_links_live.html", assigns)
  end

  @impl true
  def mount(%{"id" => post_id}, _session, socket) do
    socket = case Post.show_by_id(post_id) do
      {:ok, :get_record_by_id, _error_tag, record} ->
        if connected?(socket), do: BlogLink.subscribe()
        Process.send_after(self(), :menu, 100)
        assign(socket,
          page_title: MishkaTranslator.Gettext.dgettext("html_live", "مطلب %{title}", title: record.title),
          body_color: "#a29ac3cf",
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

  @impl true
  def handle_info(:menu, socket) do
    AdminMenu.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.AdminPostLinksLive"})
    {:noreply, socket}
  end
end
