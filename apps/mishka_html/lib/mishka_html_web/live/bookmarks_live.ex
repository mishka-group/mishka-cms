defmodule MishkaHtmlWeb.BookmarksLive do
  use MishkaHtmlWeb, :live_view

  # TODO: load bookmarks on genserver state
  # TODO: add extra info like title to genserver and alias link
  # TODO: create a task supervisor to edit all of section id which is edited in bookmark

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

end
