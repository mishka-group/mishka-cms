defmodule MishkaHtmlWeb.BookmarksLive do
  use MishkaHtmlWeb, :live_view

  alias MishkaContent.General.Bookmark

  @impl true
  def render(assigns) do
    Phoenix.View.render(MishkaHtmlWeb.ClientBlogView, "bookmarks_live.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
      bookmarks = case bookmars_paginate(user_id, 1, 20, socket) do
        nil -> []
        record -> record
      end

    socket =
      assign(socket,
        page_title: MishkaTranslator.Gettext.dgettext("html_live", "مدیریت بوکمارک کاربران"),
        user_id: user_id,
        seo_tags: seo_tags(socket),
        body_color: "#40485d",
        page_size: 20,
        page: 1,
        bookmarks: bookmarks,
        next_page: if(length(bookmarks) < 2, do: false, else: true),
        previous_page: false,
        self_pid: self()
      )
      {:ok, socket, temporary_assigns: [bookmarks: []]}
  end

  @impl true
  def handle_event("navigate_to_page", %{"section-id" => section_id}, socket) do
    socket = case MishkaContent.Cache.BookmarkManagement.get_record(socket.assigns.user_id, section_id) do
      nil ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live","به نظر می رسد بوکمارک مذکور حذف شده است."))

      record ->
        socket
        |> push_redirect(to: Routes.live_path(socket, MishkaHtmlWeb.BlogPostLive, record.extra.alias_link))
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_bookmark", %{"section-id" => section_id}, socket) do
    socket = case MishkaContent.Cache.BookmarkManagement.get_record(socket.assigns.user_id, section_id) do
      nil ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live","به نظر می رسد بوکمارک مذکور حذف شده است."))

      _record ->

        Bookmark.delete(socket.assigns.user_id, section_id)

        MishkaContent.Cache.BookmarkManagement.delete(socket.assigns.user_id, section_id)

        new_socket = case bookmars_paginate(socket.assigns.user_id, socket.assigns.page, socket.assigns.page_size, socket) do
          nil ->
            socket
            |> push_redirect(to: Routes.live_path(socket, __MODULE__))

          record ->
            socket
            |> assign(bookmarks: record)
            |> assign(previous_page: if(socket.assigns.page - 1 <= 1, do: false, else: true))
            |> assign(next_page: if(length(record) < socket.assigns.page_size, do: false, else: true))
        end

        new_socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_event("previous_page", _params, socket) do
    socket = case bookmars_paginate(socket.assigns.user_id, socket.assigns.page - 1, socket.assigns.page_size, socket) do
      nil ->
        socket
        |> assign(next_page: true)
        |> assign(previous_page: false)

      record ->
        socket
        |> assign(page: socket.assigns.page - 1)
        |> assign(next_page: true)
        |> assign(previous_page: if(socket.assigns.page - 1 <= 1, do: false, else: true))
        |> assign(bookmarks: record)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("next_page", _params, socket) do
    socket = case bookmars_paginate(socket.assigns.user_id, socket.assigns.page + 1, socket.assigns.page_size, socket) do
      nil ->
        socket
        |> put_flash(:warning, MishkaTranslator.Gettext.dgettext("html_live","بوکمارک های شما به همین تعداد می باشد"))
        |> assign(next_page: false)
        |> assign(previous_page: true)

      record ->
        socket
        |> assign(page: socket.assigns.page + 1)
        |> assign(next_page: if(length(record) < socket.assigns.page_size, do: false, else: true))
        |> assign(previous_page: if(length(record) > socket.assigns.page_size, do: false, else: true))
        |> assign(bookmarks: record)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info(_params, socket) do
    {:noreply, socket}
  end

  defp seo_tags(socket) do
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

  def bookmars_paginate(user_id, page, page_size, _socket) when is_number(page_size) do
    MishkaContent.Cache.BookmarkManagement.get_all(user_id).user_bookmarks
    |> Stream.chunk_every(page_size)
    |> Enum.at(page - 1)
  end

  def bookmars_paginate(user_id, _page, _page_size, socket) do
    MishkaContent.Cache.BookmarkManagement.get_all(user_id).user_bookmarks
    |> Stream.chunk_every(socket.assigns.page_size)
    |> Enum.at(1 - 1)
  end
end
