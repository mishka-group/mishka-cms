defmodule MishkaHtmlWeb.BookmarksLive do
  use MishkaHtmlWeb, :live_view

  # TODO: load bookmarks on genserver state
  # TODO: add extra info like title to genserver and alias link
  # TODO: create a task supervisor to edit all of section id which is edited in bookmark

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "مدیریت بوکمارک کاربران",
        seo_tags: seo_tags(socket),
        body_color: "#40485d"
      )
    {:ok, socket}
  end

  defp seo_tags(socket) do
    # TODO: should change with site address
    site_link = MishkaHtmlWeb.Router.Helpers.url(socket)
    %{
      image: "#{site_link}/images/mylogo.png",
      title: "مدیریت بوکمارک کاربران",
      description: "در این صفحه می توانید کلیه مطالبی که در سایت تگرگ بوکمارک کرده اید را مدیریت کنید",
      type: "website",
      keywords: "بوکمارک",
      link: site_link <> Routes.live_path(socket, __MODULE__)
    }
  end
end
