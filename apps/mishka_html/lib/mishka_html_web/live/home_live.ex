defmodule MishkaHtmlWeb.HomeLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.Blog.Post

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.ClientHomeView, "home_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    Process.send_after(self(), :menu, 100)
    socket =
      assign(socket,
        page_title: "صفحه اصلی وب سایت تگرگ",
        seo_tags: seo_tags(socket),
        body_color: "#40485d",
        user_id: Map.get(session, "user_id"),
        page_size: 12,
        filters: %{},
        page: 1,
        posts: Post.posts(conditions: {1, 12}, filters: %{}, user_id: Map.get(session, "user_id")),
        featured_posts: Post.posts(conditions: {1, 5}, filters: %{priority: "featured"}, user_id: Map.get(session, "user_id"))
      )

    {:ok, socket, temporary_assigns: [posts: [], featured_posts: []]}
  end

  @impl true
  def handle_info(:menu, socket) do
    ClientMenuAndNotif.notify_subscribers({:menu, "Elixir.MishkaHtmlWeb.HomeLive"})
    {:noreply, socket}
  end

  defp seo_tags(socket) do
    # TODO: should change with site address
    site_link = MishkaHtmlWeb.Router.Helpers.url(socket)
    %{
      image: "#{site_link}/images/mylogo.png",
      title: "صفحه اصلی وب سایت تگرگ",
      description: "صفحه اصلی تگرگ آخرین آثار موسیقی عکاسی وبلاگ شخصی و ویدیو های طبعیت گردی",
      type: "website",
      keywords: "تگرگ, موسقی, راک, عکاسی, ویدیو طبعیت گردی, طبیعت گردی",
      link: site_link <> Routes.live_path(socket, __MODULE__)
    }
  end
end
