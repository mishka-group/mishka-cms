defmodule MishkaHtmlWeb.BlogsLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.{Category, Post, Like}

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.ClientBlogView, "blogs_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      subscribe()
      Category.subscribe()
      Post.subscribe()
    end

    Process.send_after(self(), :menu, 100)
    user_id = Map.get(session, "user_id")
    socket =
      assign(socket,
        page_title: MishkaTranslator.Gettext.dgettext("html_live","بلاگ"),
        seo_tags: seo_tags(socket),
        page_size: 12,
        filters: %{},
        body_color: "#40485d",
        open_modal: false,
        page: 1,
        user_id: Map.get(session, "user_id"),
        posts: Post.posts(conditions: {1, 20}, filters: %{}, user_id: user_id),
        categories: Category.categories(filters: %{})
      )
      {:ok, socket, temporary_assigns: [posts: [], categories: []]}
  end

  @impl true
  def handle_params(%{"page" => page, "count" => _count}, _url, socket) do
    socket =
      socket
      |> assign(posts: Post.posts(conditions: {page, socket.assigns.page_size}, filters: socket.assigns.filters, user_id: socket.assigns.user_id), page: page)
      {:noreply, socket}
  end

  @impl true
  def handle_params(%{"page" => page}, _url, socket) do
    socket =
      socket
      |> assign(posts: Post.posts(conditions: {page, socket.assigns.page_size}, filters: socket.assigns.filters, user_id: socket.assigns.user_id), page: page)
    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("like_post", %{"post-id" => post_id}, socket) do
    socket = with {:user_id, false} <- {:user_id, is_nil(socket.assigns.user_id)},
         {:ok, :get_record_by_id, _error_tag, _repo_data} <- Post.show_by_id(post_id),
         {:error, :show_by_user_and_post_id, :not_found} <- Like.show_by_user_and_post_id(socket.assigns.user_id, post_id),
         {:ok, :add, :post_like, _like_info} <- Like.create(%{"user_id" => socket.assigns.user_id, "post_id" => post_id}) do

          notify_subscribers({:liked, socket.assigns.page})
          update_post_temporary_assigns(socket, socket.assigns.page, socket.assigns.filters, socket.assigns.user_id)
    else
      {:error, :get_record_by_id, _error_tag} ->

        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live","به نظر می رسد مطلب مذکور حذف شده است."))

      {:ok, :show_by_user_and_post_id, liked_record} ->
        Like.delete(liked_record.id)
        notify_subscribers({:liked, socket.assigns.page})
        update_post_temporary_assigns(socket, socket.assigns.page, socket.assigns.filters, socket.assigns.user_id)

      {:error, :show_by_user_and_post_id, :cast_error}  ->
          socket
          |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live","خطایی در دریافت اطلاعات وجود آماده است."))
          |> push_redirect(to: Routes.live_path(socket, __MODULE__))

      {:user_id, true} ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live","به ظاهر مشکلی وجود دارد در صورت تکرار لطفا یک بار از وب سایت خارج و دوباره وارد شوید."))
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.BlogsLive"})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:category, :ok, _repo_record}, socket) do
    {:noreply, update_category_temporary_assigns(socket)}
  end

  @impl true
  def handle_info({:post, :ok, _repo_record}, socket) do
    update_post_temporary_assigns(socket, socket.assigns.page, socket.assigns.filters, socket.assigns.user_id)
  end

  @impl true
  def handle_info({:liked, page}, socket) do
    socket = if page == socket.assigns.page do
      update_post_temporary_assigns(socket, socket.assigns.page, socket.assigns.filters, socket.assigns.user_id)
    else
      socket
    end
    {:noreply, socket}
  end


  def priority(priority) do
    case priority do
      :none -> MishkaTranslator.Gettext.dgettext("html_live","ندارد")
      :low -> MishkaTranslator.Gettext.dgettext("html_live","پایین")
      :medium -> MishkaTranslator.Gettext.dgettext("html_live","متوسط")
      :high -> MishkaTranslator.Gettext.dgettext("html_live","بالا")
      :featured -> MishkaTranslator.Gettext.dgettext("html_live","ویژه")
    end
  end

  defp update_post_temporary_assigns(socket, page, _filters, user_id) do
    update(socket, :posts, fn _posts ->
      Post.posts(conditions: {page, socket.assigns.page_size}, filters: %{}, user_id: user_id)
    end)
  end

  defp update_category_temporary_assigns(socket) do
    update(socket, :categories, fn _categories ->
      Category.categories(filters: %{})
    end)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(MishkaHtml.PubSub, "client_blogs")
  end

  def notify_subscribers({:liked, user_page}) do
    Phoenix.PubSub.broadcast(MishkaHtml.PubSub, "client_blogs", {:liked, user_page})
  end

  defp seo_tags(socket) do
    # TODO: should change with site address
    site_link = MishkaHtmlWeb.Router.Helpers.url(socket)
    %{
      image: "#{site_link}/images/mylogo.png",
      title: "وبلاگ شخصی تگرگ",
      description: "در وبلاگ شخصی من می توانید آخرین مطالب من در مورد همه چیز از جمله طبعیت گردی و موسیقی و عکاسی را پیگیری کنید",
      type: "website",
      keywords: "تگرگ, عکاسی, وبلاگ, بلاگر, ویدیو طبعیت گردی, موسیقی",
      link: site_link <> Routes.live_path(socket, __MODULE__)
    }
  end
end
